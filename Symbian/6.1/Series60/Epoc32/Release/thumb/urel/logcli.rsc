��  J�C R E A T E   T A B L E   E v e n t   ( I d   I N T E G E R   N O T   N U L L ,   E T y p e   U N S I G N E D   T I N Y I N T   N O T   N U L L ,   R�R e m o t e   C H A R ( % d ) ,   D i r e c t i o n   S M A L L I N T ,   E T i m e   D A T E   N O T   N U L L ,   D T y p e   T I N Y I N T   N O T   N U L L ,   `�D u r a t i o n   U N S I G N E D   I N T E G E R ,   S t a t u s   S M A L L I N T ,   S u b j e c t   C H A R ( % d ) ,   N u m b e r   C H A R ( % d ) ,   C o n t a c t   I N T E G E R ,   O�L i n k   U N S I G N E D   I N T E G E R ,   D a t a   L O N G   V A R B I N A R Y ,   R e c e n t   T I N Y I N T ,   D u p l i c a t e   I N T E G E R ,   O�F l a g 1   B I T   N O T   N U L L ,   F l a g 2   B I T   N O T   N U L L ,   F l a g 3   B I T   N O T   N U L L ,   F l a g 4   B I T   N O T   N U L L )  H�C R E A T E   T A B L E   T y p e   ( I d   S M A L L I N T   N O T   N U L L ,   U I d   U N S I G N E D   I N T E G E R   N O T   N U L L ,   +�D e s c r i p t i o n   C H A R ( % d )   N O T   N U L L ,   E n a b l e d   B I T )  B�C R E A T E   T A B L E   S t r i n g   ( I d   S M A L L I N T   N O T   N U L L ,   T E X T   C H A R ( % d )   N O T   N U L L )  X�C R E A T E   T A B L E   C o n f i g   ( S i z e   U N S I G N E D   S M A L L I N T   N O T   N U L L ,   R e c e n t   U N S I G N E D   T I N Y I N T   N O T   N U L L ,   �A g e   U N S I G N E D   I N T E G E R   N O T   N U L L )  &�I N S E R T   I N T O   C o n f i g   V A L U E S   ( % d ,   % d ,   % d )  B�I N S E R T   I N T O   T y p e   ( U I d ,   D e s c r i p t i o n ,   E n a b l e d )   V A L U E S   ( % d ,   ' % S ' ,   % d )  &�S E L E C T   *   F R O M   S t r i n g   W H E R E   T e x t   =   ' % S '  "�S E L E C T   *   F R O M   S t r i n g   W H E R E   I d   =   % d  !�S E L E C T   *   F R O M   T y p e   W H E R E   U I d   =   % d   �S E L E C T   *   F R O M   T y p e   W H E R E   I d   =   % d  �D E L E T E   F R O M   E v e n t   W H E R E   I d   =   % d  !�S E L E C T   *   F R O M   E v e n t   W H E R E   I d   =   % d  '�S E L E C T   *   F R O M   E v e n t   O R D E R   B Y   E T i m e   D E S C  (�S E L E C T   I d   F R O M   E v e n t   W H E R E   E T i m e   < =   # % S #  9�S E L E C T   I d ,   R e c e n t ,   D u p l i c a t e   F R O M   E v e n t   W H E R E   R e c e n t   =   % d  '�S E L E C T   I d ,   R e c e n t ,   D u p l i c a t e   F R O M   E v e n t  �S E L E C T   *   F R O M   C o n f i g  2�U P D A T E   C o n f i g   S E T   S i z e   =   % d ,   R e c e n t   =   % d ,   A g e   =   % d  ?�U P D A T E   T y p e   S E T   D e s c r i p t i o n   =   ' % S ' ,   E n a b l e d   =   % d   W H E R E   U I d   =   % d  �D E L E T E   F R O M   T y p e   W H E R E   U I d   =   % d  D�S E L E C T   I d ,   D u p l i c a t e   F R O M   E V E N T   W H E R E   R e c e n t   =   % d   % S   A N D   N O T   I d   =   % d  +�S E L E C T   I d   F R O M   E v e n t   % S   O R D E R   B Y   E T i m e   D E S C  #�S E L E C T   I d   F R O M   E v e n t   % S   A N D   I d   =   % d  ^�S E L E C T   I d ,   D u p l i c a t e   F R O M   E v e n t   W H E R E   R e c e n t   =   % d   A N D   D u p l i c a t e   I S   N U L L   % S   O R D E R   B Y   E T i m e   D E S C  m�S E L E C T   I d ,   D u p l i c a t e ,   R e c e n t   F R O M   E v e n t   W H E R E   R e c e n t   I S   N O T   N U L L   A N D   D u p l i c a t e   I S   N U L L   % S   O R D E R   B Y   E T i m e   D E S C  P�U P D A T E   E v e n t   S E T   R e c e n t   =   N U L L ,   D u p l i c a t e   =   N U L L   W H E R E   I d   =   % d   O R   D u p l i c a t e   =   % d  K�S E L E C T   I d ,   D u p l i c a t e   F R O M   E v e n t   W H E R E   D u p l i c a t e   =   % d   % S   O R D E R   B Y   E T i m e   D E S C  Q�U P D A T E   E v e n t   S E T   R e c e n t   =   N U L L ,   D u p l i c a t e   =   N U L L   W H E R E   I d   =   % d   A N D   D u p l i c a t e   =   % d  8�S E L E C T   I d   F R O M   E v e n t   W H E R E   D i r e c t i o n   =   % d   O R   S t a t u s   =   % d  �S E L E C T   I d   F R O M   S t r i n g   �D E L E T E   F R O M   S t r i n g   W H E R E   I d   =   % d  S�S E L E C T   I d ,   R e c e n t ,   D u p l i c a t e   F R O M   E v e n t   W H E R E   R e c e n t   =   % d   A N D   D u p l i c a t e   I S   N O T   N U L L   �S E L E C T   *   F R O M   S t r i n g   O R D E R   B Y   I d  �S E L E C T   *   F R O M   T y p e   O R D E R   B Y   I d  B�S E L E C T   I d ,   F l a g 1 ,   F l a g 2 ,   F l a g 3 ,   F l a g 4   F R O M   E v e n t   W H E R E   R e c e n t   =   % d �E v e n t �T y p e �S t r i n g �C o n f i g �I d �E T y p e �R e m o t e 	�D i r e c t i o n �E T i m e �D T y p e �D u r a t i o n �S t a t u s �S u b j e c t �N u m b e r �C o n t a c t �L i n k �D a t a �R e c e n t 	�D u p l i c a t e �F l a g % d �I d �U I d �E n a b l e d �D e s c r i p t i o n �I d �T e x t �S i z e �R e c e n t �A g e �% D % M % Y % 1   % 2   % 3   % H : % T : % S  D0�����`��,~�H	�	�	.
�
�
~�"��d��F�4x�@LVdrx��������� .BPV^n�������