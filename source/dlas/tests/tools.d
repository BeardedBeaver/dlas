module dlas.tests.tools;

import dlas.tools;

/// Test for helper function stringToVariant
unittest {
    assert(stringToVariant!(int, double)("0.5").peek!double !is null);
    assert(stringToVariant!(int, double)("123").peek!int !is null);
    assert(stringToVariant!(int, double)("abc").peek!string !is null);
}