----------------------------------------------------------------------
----------------------------------------------------------------------
Protocol for the 2D Displacement (image correlation)
----------------------------------------------------------------------
----------------------------------------------------------------------

Done by Alexandre Sac--Morane the 07/08/2019
alexandre.sac--morane@ens-paris-saclay.fr

----------------------------------------------------------------------
Step 0 : Global Comment
----------------------------------------------------------------------

    The goal of the code is to see displacement of the sample during test.
    The main code (main.m) is designed to compute for other things (like 3D Reconstruction)
    Variable can be not used for the 2D-Displacement but there are used for other things

    To run everything, you must have:
        - A folder with pictures
        - main.m
        - ent.m
        - PostProcessing.m
        - Displacement2D.m
        - FolderCreationAndPastingFiles.m (if the pictures are not randomly ranked)

----------------------------------------------------------------------
Step 1 : Rank pictures
----------------------------------------------------------------------

	They need to be in folder well-named. For example, all the pictures from
    the 1st spot in front are in a folder 'Front/C1'.
	We use to have a global Folder. Inside 2 Folders 'Front' or 'Behind'.
    Inside X (X is the number of spots) Folders 'Ci' (i is the number of the spot)

    Comment : The Matlab code FolderCreationAndCopyingFiles.m can create Folders
    and paste pictures but the pictures must be ranked (1st spot - 2nd spot - 1st spot - 2nd spot - etc)
    and DigicamControl (the software used) is random.

----------------------------------------------------------------------
Step 2 : Data Information
----------------------------------------------------------------------

    On the main code (Main.m), there is a section with data information.
    They must given. At the end, the file name must be as the following
    Date_NCamera_Specificity_SandKind_Speed_Pressure_TimeLapse

    With :
        Date : the day of today, format recommended 'DDMONTHYEAR'
        NCamera : the number of the spot. If there is Front or Behind, it is recommended
        to put string 'F' or 'B'
        Specificity :  the specificity of the sand (fractal indice or granulometry)
        Sand : kind of sand (Durham)
        Speed : speed of the plate
        Pressure : confinement pressure
        TimeLapse : time between picture of a same spot

    Comment : All this information is string, except NCamera because it is used in the following code

    The name of the Folder must be given also

----------------------------------------------------------------------
Step 3 : Select the extract zone
----------------------------------------------------------------------

    Now, it begins to be a little tricky. You must compute the Data Information
    section ('Run Section' on Matlab or 'command'+'Enter').
    Then compute the section nammed 'Show the picture and select the extract zone'.
    This section is in an 'if' part, you must select it (without 'if' and 'end')
    and put it in the Command Window of Matlab.

    Different figures open and on the left top there is a square.
    Move and distort the square on the zone you want to study.
    'Click right' on the square and 'Copy position'
    Paste on the Command Window. The format is as following

    [Start_zone_column Start_zone_line Width_zone_column Width_zone_line]

    With :
        Start_zone_column : the number of the column where the zone starts
        Start_zone_line : the number of the line where the zone starts
        Width_zone_column : the number of columns of the zone
        Width_zone_line : the number of lines of the zone

    When you have pasted, you can fill the variable 'extraction'
    This variable is built on the following format
    Each column is about one camera (the first one is the fist spot, etc)
    Each column is [e1sl ; e1el ; e1sc ; e1ec]

     With :
        e1sl : (Element 1 Starter Line) the number of the line where the zone starts
        e1el : (Element 1 End Line) the number of the line where the zone ends
        e1sc : (Element 1 Starter Column) the number of the column where the zone starts
        e1ec : (Element 1 End Column) the number of the column where the zone ends

    Comment : If we can automate this step it can be nice.
    This extract parameters are for the same for all times by 1 spot.
    As the plate is rising, the down part of the extract zone is not sample.


    One thing important is the scalling factor and the converting between
    pixel measure and meter measure.
    On the figures, you see black straight on the membrane.
    Depends on the width of this membrane (I use to have 10 cm width).
    Select with the square the straight, copy and paste as sooner.
    The last number is the number of lines in pixel of the straight.
    Fill the variable 'thalesL'
    The fist number is for the spot 1 etc...
    You must to put measure in real life in meter / measure on focal plan in pixels
    So I use to put 0.1/number of line in pixel


    Another point is the orientation of the camera.
    It depends on the position of the camera in the setup
    Check if the orientation of the picture is good with figures
    Fill the variable PictureOrientation, the first number is for the first spot etc...
    I use to put -90, 0 or +90.

----------------------------------------------------------------------
Step 4 : Computing information
----------------------------------------------------------------------

    Before to run the code, code parameters must be given
    You can change
        TimeStep : this parameter is about pictures in 1 folder of 1 spot.
    The correlation code uses to compare 2 pictures and see the differences.
    Here the code will compare picture number i with picture number i+TimeStep
    You can have so the the time between two results (TimeStep * TimeLapse)
        thales : this parameter convert pixel measure on meter measure (We will talk about)
        limit : this is the number of the lines and column between the border
    of the extract zone and the first discretisation.
        SpatiaStep : the number of line and column between 2 discretisations.
        SizePixel : size of 1 discretisation with the format [Number_of_lines Number_of_columns]

    Comment : You can change SpatialStep and TimeStep to speed up the code running.
    You have to change SizePixel following your sample (see next step)

----------------------------------------------------------------------
Step 5 : Size of the discretisation
----------------------------------------------------------------------

    The quality of the resultat depends a lot on this parameter 'SizePixel'.
    It must not be too large and not be too small.
    It depends on the sand tested, if the granulometry is high, you have to use
    large discretisation for example.
    To see the discretisation of one picture, it is a little tricky
    You must to run the computing information (expecially
    e1sl,e1el,e1sc,e1ec,SpatialStep,SizePixel)
    Go to the section nammed 'To see the discretisation'
    in the part with 'if'
    Copy and paste without 'if' and 'end'
    A figure opens and show you the discretisation

    Comment : If we can be easier for this step it can be nice

----------------------------------------------------------------------
Step 6 : Running
----------------------------------------------------------------------

    In the section 'What do you want ?', check if the function 'Displacement2D'
    is the only uncommented.
    Run
    On Command Window, 2 lines appear
    the first one is about the iteration on time
    the second one is about the iteration on space for each time (in percentage)

    Comment : If the resultat is not good, it is maybe because of the SearchZone
    You can go in 'Displacement2D.m' function, and change the value of SZls,SZle,SZcs,SZce
        SZls : Search Zone Line Start
        SZle : Search Zone Line End
        SZcs : Search Zone Column Start
        SZce : Search Zone Column End
    The increase of the plate can be computed, you must fix the parameter p2
    in the function 'Displacement2D.m'. If it can be automate it will be nice

----------------------------------------------------------------------
Step 6 : Post Processing
----------------------------------------------------------------------
    Go to 'PostProcessing.m' Matlab function.
    Here you can show results and you can apply data correction
    You have only to put the good file on the variable 's' and the value of
    the time lapse parameter 'TimeLapse'.
    A first figure opens to show you the extract zone
    Others figure open to show you displacement and deformation during time.
    The displacement and deformation are computed between 2 times (TimeLapse*StepTime)
    A last figure open and show you the evolution of the shearband width

    Comment : Data correction is coded but not in this function
    The shear band detection is not working good.

----------------------------------------------------------------------
Step 7 : Save data
----------------------------------------------------------------------

    Save and comment on file nammed 'Info.txt'
    You can comment wich spot is good
    Save following data :
        - extraction
        - PictureOrientation
        - thalesL
        - TimeStep
        - limit
        - SpatialStep
        - SizePixel


----------------------------------------------------------------------
Step 8 : Other thing
----------------------------------------------------------------------

    Soon...
