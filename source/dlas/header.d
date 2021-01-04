module dlas.header;

import std.variant;

/// Represents one entry (typically one line) of LAS file header 
/// contained in ~WELL and ~PARAMETER sections
struct LasHeaderEntry {
    string name;        ///< Name of this entry
    Variant value;      ///< Value of this entry
    string unit;        ///< Unit of measurment if appliable
    string comment;     ///< Comment as it is written in LAS file
}

/// Represents one entry of LAS data header. This data is contained
/// in a ~CURVE section
struct LasDataHeaderEntry {
    string name;        ///< Name of this curve
    string unit;        ///< Unit of measurment
    string apiCode;     ///< Curve API code
    string comment;     ///< Comment as it is written in LAS file
}