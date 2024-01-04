function(_cforge_option_parse_if_expr <if-expr>)
    # <if-expr> has the format <value> [IF <condition-expr>]
endfunction()

function(cforge_option_group <option-group-name>
    DEPENDS-ON <condition-expr>)
endfunction()

function(cforge_option_end_group [<option-group-name>])
endfunction()

function(cforge_option_type <option-type-name>
    TYPE <type>
    PROPERTIES <type-properties>
    DOC <doc-string>
    DEFAULT <value> [IF <condition-expr>]
)
endfunction()

function(cforge_option <option-name>
    TYPE <type>
    PROPERTIES <type-properties>
    PROMPT <prompt-string>
    DOC <doc-string>
    DEFAULT <value> [IF <condition-expr>]
    DEPENDS-ON <condition-expr>
    SELECT <symbol> [IF <condition-expr>]
    VISIBLE-IF <condition-expr>)
    # <type> is one of: BOOL, INT, STRING, PATH, FILEPATH, or a type defined by cforge_option_type()
    # <type-properties>:
    #   INT: MIN, MAX, ENUM, BASE
    #   STRING: ENUM
    # The BASE property can be one of the supported bases (BIN, OCT, DEC, HEX, or the corresponding numbers 2, 8, 10, 16)
    # The ENUM property is a semicolon-separated list of values
    # MIN, MAX and ENUM values must respect the type specified (and BASE if any)
    # Properties are defined using define_property(VARIABLE) and set using set_property(VARIABLE)
endfunction()
