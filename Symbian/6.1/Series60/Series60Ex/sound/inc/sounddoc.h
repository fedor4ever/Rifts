// Copyright (c)2001, Nokia. All rights reserved.

#ifndef __SOUNDDOC_H__
#define __SOUNDDOC_H__

#include <eikdoc.h>

/*! 
  @class CCSAsyncDocument
  
  @discussion An instance of class CSoundDocument is the Document part of the AVKON
  application framework for the Sound example application
  */
class CSoundDocument : public CEikDocument
    {
public:
/*!
  @function NewL
  
  @discussion Construct a CSoundDocument for the AVKON application aApp 
  using two phase construction, and return a pointer to the created object
  @param aApp application creating this document
  @result a pointer to the created instance of CSoundDocument
  */
    static CSoundDocument* NewL(CEikApplication& aApp);

/*!
  @function NewLC
  
  @discussion Construct a CSoundDocument for the AVKON application aApp 
  using two phase construction, and return a pointer to the created object
  @param aApp application creating this document
  @result a pointer to the created instance of CSoundDocument
  */
    static CSoundDocument* NewLC(CEikApplication& aApp);

public: // from CEikDocument
/*!
  @function CreateAppUiL 
  
  @discussion Create a CSoundAppUi object and return a pointer to it
  @result a pointer to the created instance of the AppUi created
  */
    CEikAppUi* CreateAppUiL();

private:

/*!
  @function ConstructL
  
  @discussion Perform the second phase construction of a CSoundDocument object
  */
    void ConstructL();

/*!
  @function CSoundDocument
  
  @discussion Perform the first phase of two phase construction 
  @param aApp application creating this document
  */
    CSoundDocument(CEikApplication& aApp);

    };


#endif // __SOUNDDOC_H__

