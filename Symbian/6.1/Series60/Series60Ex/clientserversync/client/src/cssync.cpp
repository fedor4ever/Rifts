/* Copyright (c) 2001, Nokia. All rights reserved */

#include "CSSyncApplication.h"

// Epoc DLL entry point, return that everything is ok
GLDEF_C TInt E32Dll(TDllReason)
    {
    return KErrNone;
    }


// Create an CSSync application, and return a pointer to it
EXPORT_C CApaApplication* NewApplication()
    {
    return (new CCSSyncApplication);
    }

