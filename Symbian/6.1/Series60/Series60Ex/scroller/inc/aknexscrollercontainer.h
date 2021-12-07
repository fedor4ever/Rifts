/*
* ============================================================================
*  Name     : CAknExScrollerContainer from CCoeControl, MCoeControlObserver
*  Part of  : AknExScroller
*  Copyright (c) 2003 Nokia. All rights reserved.
* ============================================================================
*/

#ifndef AKNEXSCROLLERCONTAINER_H
#define AKNEXSCROLLERCONTAINER_H

// INCLUDES
#include <aknview.h>

   
// FORWARD DECLARATIONS
class CEikLabel;        // labels


// CLASS DECLARATION
/**
*  CAknExScrollerContainer  
*  container control class for View1.
*  
*/
class CAknExScrollerContainer : public CCoeControl, MCoeControlObserver
    {
    public: // Constructors and destructor
        /**
        * C++ default constructor.
        */
        CAknExScrollerContainer();

        /**
        * EPOC default constructor.
        * @param aRect Frame rectangle for container.
        */
        void ConstructL( const TRect& aRect );

        /**
        * Destructor.
        */
        virtual ~CAknExScrollerContainer();


    private: // Functions from base classes
        /**
        * From CoeControl,SizeChanged.
        */
        void SizeChanged();

        /**
        * From CoeControl,CountComponentControls.
        * @return Number of component controls 
        */
        TInt CountComponentControls() const;

        /**
        * From CCoeControl,ComponentControl.
        * @param Specification for component pointer
        * @return Pointer to component control
        */
        CCoeControl* ComponentControl( TInt aIndex ) const;

        /**
        * From CCoeControl,Draw.
        * @param Specified area for drawing
        */
        void Draw( const TRect& aRect ) const;

        /**
        * From MCoeControlObserver,
        *   Handles an event of type aEventType reported
        *   by the control aControl to this observer.
        *   And it is a pure virtual function in MCoeControlObserver.
        *   We must implement it, despite empty.
        * @param Pointer to component control
        * @param Event Code
        */
        void HandleControlEventL( CCoeControl* /* aControl */,
                                  TCoeEvent /* aEventType */ );
      

    private: //data
        CEikLabel* iLabel;        // label
        CEikLabel* iDoLabel;      // label

    };

#endif // AKNEXSCROLLERCONTAINER_H

// End of File
