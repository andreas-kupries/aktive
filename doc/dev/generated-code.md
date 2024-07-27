<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||
|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|[Developer Index ↗](index.md)|


# Code generated from specifications

## Types

Per declared user type the generator emits

  - A function declaration for the type's converter function.

  - An implementation for this function. The implementation wraps the C code fragment provided to
    the type in its DSL declaration command.

Note that the set of types contains not just the base types, but also the vector types derived from
a base type. For the vector types the converter is completely generated, and references the
converter function of the base type.

### Vector Types

Per vector type the generator further emits

  - A structure type to hold the dynamic data of the vector, i.e. count of elements and the C array
    of the elements themselves.

  - Function declarations for functions to allocate and release vector structures.

  - The implementations of the above functions.

Note: The allocation functions actually transform a pre-existing vector structure into one where the
elements reside in the heap. The pre-existing structure may have its elements anywhere (stack, heap,
...). Because of this the process is also called `heapification` and the functions use the suffix
`_heapify` in their names.

## Operators

Per operator returning an __image result__ and __no input images requiring ignore signaling__ the
code generator emits

  - A function declaration for a C level constructor function (Name suffix `_new`). This function
    takes a parameter structure, the input image arguments, and returns the declared
    result. Parameter structure and images are optional, i.e. appear if and only if the operator has
    parameters and/or input images.

    Note that the exact nature of the image argument depends on the declared reference counting mode
    of the argument. Inputs which may be ignored, or not, get a second argument through which the
    constructor can signal if the input was actually ignored, or not.

    Parameter data is provided before image arguments.

  - A function implementation for the above. This implementation contains a variable of type
    `aktive_image_type` describing the operation to the runtime function `aktive_image_new`.

    This description contains

      - The name of the operation.
      - The size of the parameter structure, or `0`, for operations without parameters.
      - The number of parameters.
      - A link to the operations parameter descriptor structure. See next section.

    For operators with a fixed number of input images the generatored constructor collects the
    arguments into a stack-located vector structure which is then provided to `active_image_new`.

    If the operator has only a variadic input image the associated argument is simply passed
    through, as it already is the proper vector structure.

    __ATTENTION__: A combination of fixed and variadic input images is currently __not handled__ by
    the generator. It improperly collects only the fixed part. So far no operator thought of
    required this.

  - A placeholder function for the operator implementation, i.e. the calculation of pixels.

    The signature of this placeholder is in flux.

Per operator returning an __image result__ and having __inputs requiring signaling__ the code
generator emits:

  - A function declaration as above.

  - A placeholder implementation.

Per operator returning a __non-image result__ the code generator emits

  - A placeholder function (Name suffix `_get`) taking parameters (if any), the single (!?) input
    image and returning a value of the desired type.

    The signature of this placeholder is in flux.

Per operator returning __no results__ the code generator emits

  - A placeholder function (Name suffix `_do`) taking parameters (if any), and the single (!?) input
    image.

    The signature of this placeholder is in flux.

Per operator, regardless of kind, the code generator emits

  - A `critcl::cproc` Tcl level constructor command. This command takes the parameters, if any as
    regular arguments, followed by any image arguments, if any.

    Its implementation collects any parameter values into stack-located parameter block for the
    operation in question. Here is why user type required only a conversion from C to Tcl_Obj*. The
    conversion from Tcl_Obj* to C is here, hidden within the Critcl argument type associated with
    the user type.

    After setting up parameters, etc. the implementation invokes the C level function for the
    operator. The constructor, the getter, or the do'er, as per the above items.

    The implementation properly handles ref-counting of each input image, as per its declared mode.

### Parameters

Per operator which has one or more parameters the generator emits:

  - A structure definition `aktive_image_XXXXX_param` containing one field per parameter, using the
    parameter's name and C type. The parameter descriptions document the fields.

  - An array variable `aktive_image_XXXXX_descriptor` of type `aktive_image_parameter` describing
    the structure of the previous item, i.e. providing, per parameter:

      - The associated symbol (and through that the name as string)
      - The index into the description variable (and thus the description as string)
      - A symbol for the user type, and
      - The offset of the field in the param structure

    The last two elements provide the runtime with all the data it needs (field size, offset, and
    converter) to read values from the fields and convert them to equivalent Tcl_Obj* values.

#### Variadics

For operations with a variadic parameter the code generator further emits:

  - A set of function declarations to heapify and release (see vector types) the vector field of the
    parameter structure.

  - A set of function implementations for the above.
