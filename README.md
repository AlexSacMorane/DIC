Protocol for the 2D Displacement (image correlation)
----------------------------------------------------------------------
----------------------------------------------------------------------

Done by Alexandre Sac--Morane the 07/08/2019
alexandre.sac--morane@ens-paris-saclay.fr

Adapted by Alexandre Sac--Morane the 03/11/2023
alexandre.Sac-morane@uclouvain.be

----------------------------------------------------------------------
Step 0 : Global Comment
----------------------------------------------------------------------

    The goal of the code is to see displacement of the sample during test.

    To run DIC algorithm, you must have:
        - A folder with pictures
        - The Matlab file main.m
        - The Matlab file ent.m
        - The Matlab file PostProcessing.m
        - The Matlab file Displacement2D.m

----------------------------------------------------------------------
Step 1 : Rank pictures
----------------------------------------------------------------------

	The pictures need to be in folder well-named. It should have one folder per camera spot.

----------------------------------------------------------------------
Step 2 : Data Information
----------------------------------------------------------------------

    The name of the folder (the one with the pictures) must be given (as a string)
    The name must be given also. It will be the name of the postproccessing. It must end with '.mat'

----------------------------------------------------------------------
Step 3 : Select the extract zone
----------------------------------------------------------------------

    Now, it begins to be a little tricky.

    You must compute the Data Information section ('Run Section' on Matlab or 'command'+'Enter').

    Then compute the section nammed 'Show the picture and select the extract zone'.
    This section is in an 'if' part, put '1==1' if you want to run it, else put '1==0' (it won't help for the latter).

    One figure open and on the left top there is a square.
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
    Each column is [e1sl ; e1el ; e1sc ; e1ec]

     With :
        e1sl : (Element 1 Starter Line) the number of the line where the zone starts
        e1el : (Element 1 End Line) the number of the line where the zone ends
        e1sc : (Element 1 Starter Column) the number of the column where the zone starts
        e1ec : (Element 1 End Column) the number of the column where the zone ends

    So, with previous manipulation:
       e1sl = Start_zone_line
       e1el = Start_zone_line + Width_zone_line
       e1sc = Start_zone_column
       e1ec = Start_zone_column + Width_zone_column

    Comment : If we can automate this step it can be nice.
    This extract parameters are for the same for all times by 1 spot.
    As the plate is rising, the down part of the extract zone is not sample.


    One thing important is the scalling factor and the converting between
    pixel measure and meter measure.
    On the figure, you see black line on the membrane.
    Depends on the length of this line (I use to have 10 cm length).
    Select with the square the line, copy and paste as sooner to get the number of pixel of this line.
    The last number is the number of lines in pixel of the line.
    Fill the variable 'thalesL'
    You must to put measure in real life in meter / measure on focal plan in pixels
    So I use to put 0.1/number of line in pixel


    Another point is the orientation of the camera.
    It depends on the position of the camera in the setup
    Check if the orientation of the picture is good with figures
    Fill the variable PictureOrientation.
    I use to put -90, 0 or +90.


    You can close the figure you used and put '1==0' in the if line to not reopen a new figure.

----------------------------------------------------------------------
Step 4 : Computing information
----------------------------------------------------------------------

    Before to run the code, code parameters must be given
    You can change
        TimeStep : this parameter is about pictures in 1 folder of 1 spot.
    The correlation code uses to compare 2 pictures and see the differences.
    Here the code will compare picture number i with picture number i+TimeStep
    You can have so the the time between two results (TimeStep * TimeLapse)
        thales : this parameter convert pixel measure on meter measure
        limit : this is the number of the lines and column between the border of the extract zone and the first discretisation.
        SpatiaStep : the number of line and column between 2 discretisations.
        SizePixel : size of 1 discretisation with the format [Number_of_lines Number_of_columns]
    It is linked to the variable SizePixelValue

    Comment : You can change SpatialStep and TimeStep to speed up the code running.
    You have to change SizePixel following your sample (see next step)

----------------------------------------------------------------------
Step 5 : Size of the discretisation
----------------------------------------------------------------------

    The quality of the resultat depends a lot on this parameter 'SizePixel'.
    It must not be too large and not be too small.
    It depends on the sand tested, if the granulometry is high, you have to use large discretisation for example.

    To see the discretisation of one picture, it is a little tricky.
    You must to run the previous sections.
    (expecially: e1sl, e1el, e1sc, e1ec, SpatialStep, SizePixel, FolderName, Orientation)

    Then compute the section nammed 'To see the discretisation'.
    This section is in an 'if' part, put '1==1' if you want to run it, else put '1==0' (it won't help for the latter).
    A figure opens and show you the discretisation

----------------------------------------------------------------------
Step 6 : Running
----------------------------------------------------------------------

    Check if the sections 'Show the picture and select the extract zone' and 'To see the discretisation' are weel set with 'if 1==0'
    (you do not want to run those parts, it was a preliminary work)

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

    Save following data :
        - Displacement
    This is a structure with the discretization following x and y, the displacement following x and y and a returning map
        - extraction
        - the images (not needed and can take space, you can delete this save)
        - PictureOrientation
        - thalesL
        - TimeStep
        - limit
        - SpatialStep
        - SizePixel

    The data are saved in the folder you gave with the name you gave.

----------------------------------------------------------------------
Step 8 : Post Processing
----------------------------------------------------------------------

    Now we can open the PostProcessing.m file

    In the section 'Parameters of the post proccessing', you need to fill :
        - The name of the Folder
        - The name of the data file
        - the min and max value for the strain (only display parameters)
        - the starting and ending times

    A strain is computed from the displacement map.
    A correction algorithm is applied to avoid errors.
