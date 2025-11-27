# GoRPC
Hello future me and other curious developers snooping.

This page is for my reference whenever I need to remind myself on details in the world of Golang.

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
    1. `cd` into the directory that contains the `.proto` file
    2. Run `protoc --go_out=. address_book.proto` to generate a `*.pb.go` file



What does the `*pb.go` file contain?
    1. Go structs for every message in your `proto`
        Example:
        ```proto
        message Person {
            string name = 1;
            int32 id = 2;
        }
        ```
        Becomes:
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
    2. Serialization and Deserialization
        The `*.pb.go` file includes methods to convert your structs into efficient, cross-language protobuf bytes
            ```go
            data, err := proto.Marshal(p)
            ```
        And decode them:
            ```go
            var out Person;
            proto.Unmarshal(data, &out)
            ```

        

