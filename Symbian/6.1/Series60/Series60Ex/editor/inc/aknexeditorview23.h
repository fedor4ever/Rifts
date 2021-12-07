/*
* ============================================================================
*  Name     : CAknExEditorView23 from CAknView
*  Part of  : AknExEditor
*  Copyright (c) 2003 Nokia. All rights reserved.
* ============================================================================
*/

#ifndef AKNEXEDITORVIEW23_H
#define AKNEXEDITORVIEW23_H

// INCLUDES
#include <aknview.h>

// CONSTANTS
// UID of view
const TUid KViewId23 = {23};

// FORWARD DECLARATIONS
class CAknExEditorContainer23;

// CLASS DECLARATION

/**
*  CAknExEditorView23 view class.
* 
*/
class CAknExEditorView23 : public CAknView
    {
    public: // Constructors and destructor
        /**
        * C++ default constructor
        */
        CAknExEditorView23();

        /**
        * EPOC default constructor.
        */
        void ConstructL();

        /**
        * Destructor.
        */
        virtual ~CAknExEditorView23();

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
        CAknExEditorContainer23* iContainer;
    };

#endif  // AKNEXEDITORVIEW23_H

// End of File
