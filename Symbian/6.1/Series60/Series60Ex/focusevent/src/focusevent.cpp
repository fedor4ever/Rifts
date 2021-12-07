/* Copyright (c) 2001, Nokia. All rights reserved */
#include "FocusEventApplication.h"

// Epoc DLL entry point, return that everything is ok
GLDEF_C TInt E32Dll(TDllReason)
    {
    return KErrNone;
    }


// Create an IncommingCall application, and return a pointer to it
EXPORT_C CApaApplication* NewApplication()
    {
    return (new CFocusEventApplication);
    }

