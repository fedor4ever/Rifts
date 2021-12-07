/*
* ============================================================================
*  Name     : CAknExEditorView33 from CAknView
*  Part of  : AknExEditor
*  Copyright (c) 2003 Nokia. All rights reserved.
* ============================================================================
*/

#ifndef AKNEXEDITORVIEW33_H
#define AKNEXEDITORIVEW33_H

// INCLUDES
#include <aknview.h>

// CONSTANTS
// UID of view
const TUid KViewId33 = {33};

// FORWARD DECLARATIONS
class CAknExEditorContainer33;

// CLASS DECLARATION

/**
*  CAknExEditorView33 view class.
* 
*/
class CAknExEditorView33 : public CAknView
    {
    public: // Constructors and destructor
        /**
        * C++ default constructor
        */
        CAknExEditorView33();

        /**
        * EPOC default constructor.
        */
        void ConstructL();

        /**
        * Destructor.
        */
        virtual ~CAknExEditorView33();

    public: // Functions from base classes
        
        /**
        * From CAknView, Returns the ID of view.
        * @return Returns the ID of view.
        */
        TUid Id() const;

        /**
        * From CAknView, Handles the commands.
        * @pram aCommand Command to be handled.
        */
        void HandleCommandL(TInt aCommand);

        /**
        * From CAknView, Handles the clientrect.
        */
        void HandleClientRectChange();

    private:

        /**
        * From CAknView, Creates the Container class object.
        * @param aPrevViewId This is not used now.
        * @param aCustomMessage This is not used now.
        * @param aCustomMessage This is not used now.
        */
        void DoActivateL(const TVwsViewId& /*aPrevViewId*/,
                         TUid /*aCustomMessageId*/,
                         const TDesC8& /*aCustomMessage*/);

        /**
        * From AknView, Deletes the Container class object.
        */
        void DoDeactivate();

    private: // Data

        CAknExEditorContainer33*    iContainer;


    };

#endif  // AKNEXEDITORVIEW33_H

// End of File
