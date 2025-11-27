# GoRPC
Hello future me and other curious developers snooping.

This page is for my reference whenever I need to remind myself on details in the world of Golang.

## Go

### Package Names
Usually director name = package name, **EXCEPT** when you want to build an executable program.

If a file contains `func main()`, the package declaration at the top **MUST** be `package main`, regardless of the directory name

## Protocol Buffers (Protobufs)

### `go_package`
Defines the import path of the package that has all the generated code for this file. The Go package name will be the last path component of the import path.

```proto
option go_package = "github.com/protocolbuffers/protobuf/examples/go/tutorialpb";
```

### Message Definitions
Aggregate containing a set of typed fields.
```proto
message Person {
    string name = 1;
    int32 id = 2; // Unique ID number for this person
    string email = 3;

    message PhoneNumber {
        string number = 1;
        PhoneType type = 2;
    }

    repeated PhoneNumber phones = 4;

    google.protobuf.Timestamp last_updated = 5;
}

enum PhoneType {
    PHONE_TYPE_UNSPECIFIED = 0;
    PHONE_TYPE_MOBILE = 1;
    PHONE_TYPE_HOME = 2;
    PHONE_TYPE_WORK = 3;
}

// our address book file is just one of these
message AddressBook {
    repeated Person people = 1;
}
```

The `=1`, `=2` markers on each element identify the unique "tag" that field uses in the binary encoding
    * Tag numbers 1 - 15 require one less byte to encode than higher numbers, so these are used for commonly used or repeated elements
    * Tag numbers >= 16 for less frequently used optional elements

### Compiling Protocol Buffers
Next, we need to generate the classes you'll need to read and write `AddressBook` (and also `Person` and `PhoneNumber`) messages. We do this by running the protocol buffer compiler `protoc` on your `.proto`

**Goal**: We want to turn our `.proto` definitions into **real, usable Go-code**
* A `.proto` is not **executable** - just a schema
* `address_book.pb.go` is the compiled output that your Go program actually imports and uses at runtime

Protobuf workflow:
```
.proto definitions → protoc + plugin → generated Go source → import in your project
```

Steps:
1. `cd` to the project root
2. Install the compiler and gRPC plugins
```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```
3. Add it to your `PATH`
```bash
export PATH="$PATH:$(go env GOPATH)/bin"
```
4. Run protoc to generate a `*.pb.go` file in the same directory as the `.proto` file
```bash
protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    api/proto/v1/scheduler.proto
```


#### What does the `*pb.go` file contain?

##### Go structs for every message in your `proto`
Take a proto definition:
```proto
message Person {
    string name = 1;
    int32 id = 2;
}
```

Go-generated code becomes:
```go
type Person struct {
    Name string
    Id   int32
}
```

You can now write:
```go
p := &tutorial.Person{
    Name: "JSON",
    Id: 123
}
```


#### Serialization and Deserialization
The `*.pb.go` file includes methods to convert your structs into efficient, cross-language protobuf bytes
```go
data, err := proto.Marshal(p)
```

And decode them:
```go
var out Person;
proto.Unmarshal(data, &out)
```

        

