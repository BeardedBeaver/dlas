module dlas.tests.loader;

import dlas.header;
import dlas.loader;

import std.math;

/// Tests for retrieveing LAS version
unittest {
    auto loader = new Loader;
    immutable int v = loader.lasVersion("./test/sample_2.0.las");
    assert(v == 2);
}

/// Tests for retrieveing delimiter symbol
unittest {
    auto loader = new Loader;
    string delimiter;
    
    delimiter = loader.delimiter("./test/sample_2.0.las");
    assert(delimiter == " ");

    delimiter = loader.delimiter("./test/sample_3.0.las");
    assert(delimiter == ",");
}

/// Tests for reading LAS header
unittest {
    auto loader = new Loader;
    auto header = loader.loadLasHeader("./test/sample_2.0.las");
    assert(header.length == 20);

    assert(header["STRT"].name == "STRT");
    assert(header["STRT"].value == 1670.0);
    assert(header["STRT"].unit == "M");
    assert(header["STRT"].comment == "START DEPTH");
    
    assert(header["COMP"].name == "COMP");
    assert(header["COMP"].value == "ANY OIL COMPANY INC.");
    assert(header["COMP"].unit == "");
    assert(header["COMP"].comment == "COMPANY");

}

/// Tests for reading LAS data header
unittest {
    auto loader = new Loader;
    auto header = loader.loadLasDataHeader("./test/sample_2.0.las");
    assert(header.length == 8);
    assert(header[0].name == "DEPT");
    assert(header[1].name == "DT");
    assert(header[1].unit == "US/M");
    assert(header[1].apiCode == "60 520 32 00");
    assert(header[1].comment == "2  SONIC TRANSIT TIME");
}

/// Tests for reading LAS data
unittest {
    auto loader = new Loader;
    auto data = loader.loadLasData("./test/sample_2.0.las");
    assert(data.length == 8);

    assert(approxEqual(data[0][0], 1670));
    assert(approxEqual(data[0][1], 1669.875));
    assert(approxEqual(data[0][2], 1669.750));

    assert(approxEqual(data[2][0], 2550));
    assert(approxEqual(data[2][1], 2550));
    assert(approxEqual(data[2][2], 2550));

    auto md = data[0][];
    import std.stdio;
    writeln(md);
}