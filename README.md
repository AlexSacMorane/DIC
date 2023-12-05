Protocol for the 2D Displacement (image correlation)
----------------------------------------------------------------------
----------------------------------------------------------------------

Done by Alexandre Sac--Morane the 07/08/2019
alexandre.sac--morane@ens-paris-saclay.fr

Adapted by Alexandre Sac--Morane the 03/11/2023
alexandre.sac-morane@uclouvain.be

Please cite the following article: <br>
Rattez H, Shi Y, Sac-Morane A, Klaeyle T, Mielniczuk B, Veveakis M (2022) Effect of grain size distribution on the shear band thickness evolution in sand. Géotechnique 72: 350-363. https://doi.org/10.1680/jgeot.20.P.120

----------------------------------------------------------------------
Step 0 : Global Comment
----------------------------------------------------------------------

    The goal of the code is to see the displacement of the sample during the test.

    To run DIC algorithm, you must have:
        - A folder with pictures
        - The Matlab file Main.m
        - The Matlab file ent.m
        - The Matlab file Displacement2D.m

    You must create folders png, save

----------------------------------------------------------------------
Step 1 : Data Information
----------------------------------------------------------------------

    The name of the folder (the one with the pictures) must be given (as a string)
    The name must be given also. It will be the name of the postproccessing. It must end with '.mat'

----------------------------------------------------------------------
Step 2 : Rank pictures
----------------------------------------------------------------------

	The pictures need to be in a folder well-named. It should have one folder per camera spot.
 	Moreover, the name of the picture should be templateXXX.extension
  	where XXX is the index of the picture (could be XX if there are less than 100 pictures, and X if there are less than 10 pictures)

	If this is not the case : 
    	- run section Data information
    	- in the section Sort pictures :
			- put 1==1
   			- give the template of your pictures (the variable is template_name)
   			- give the extension of your pictures (the variable is extension_name)
    	- run section Sort pictures
    	- put 1==0 in the section Sort pictures

	Be careful, this step will change the name of your pictures.

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

    When you have pasted, you can fill in the variable 'extraction'
    Each column is [e1sl ; e1el ; e1sc ; e1ec]

     With :
        e1sl : (Element 1 Starter Line) the number of the line where the zone starts
        e1el : (Element 1 End Line) the number of the line where the zone ends
        e1sc : (Element 1 Starter Column) the number of the column where the zone starts
        e1ec : (Element 1 End Column) the number of the column where the zone ends

    So, with the previous manipulation:
       e1sl = Start_zone_line
       e1el = Start_zone_line + Width_zone_line
       e1sc = Start_zone_column
       e1ec = Start_zone_column + Width_zone_column

    Comment : If we can automate this step it can be nice.
    These extract parameters are the same for all times by 1 spot.
    As the plate rises, the down part of the extracted zone is not sample.


    One thing important is the scaling factor and the converting between
    pixel measure and meter measure.
    In the figure, you see a black line on the membrane.
    Depends on the length of this line (I use to have 10 cm length).
    Select with the square the line, copy and paste as soon as possible to get the number of pixel of this line.
    The last number is the number of lines in pixel of the line.
    Fill in the variable 'thalesL'
    You must put measure in real life in meter / measure on focal plan in pixels
    So I use to put 0.1/number of line in pixel


    Another point is the orientation of the camera.
    It depends on the position of the camera in the setup
    Check if the orientation of the picture is good with figures
    Fill in the variable PictureOrientation.
    I use to put -90, 0 or +90.


    You can close the figure you used and put '1==0' in the if line to not reopen a new figure.

----------------------------------------------------------------------
Step 4 : Computing information
----------------------------------------------------------------------

    Before running the code, code parameters must be given
    You can change
        TimeStep : this parameter is about pictures in 1 folder of 1 spot.
    The correlation code is used to compare 2 pictures and see the differences.
    Here the code will compare picture number i with picture number i+TimeStep
    You can have the time between two results (TimeStep * TimeLapse)
        thales : this parameter converts pixel measure on meter measure
        limit : this is the number of lines and columns between the border of the extracted zone and the first discretisation.
        SpatiaStep : the number of lines and columns between 2 discretisations.
        SizePixel : size of 1 discretisation with the format [Number_of_lines Number_of_columns]
    It is linked to the variable SizePixelValue

    Comment : You can change SpatialStep and TimeStep to speed up the code running.
    You have to change SizePixel following your sample (see next step)

----------------------------------------------------------------------
Step 5 : Size of the discretisation
----------------------------------------------------------------------

    The quality of the result depends a lot on this parameter 'SizePixel'.
    It must not be too large and not too small.
    It depends on the sand tested, if the granulometry is high, you have to use large discretisation for example.

    To see the discretisation of one picture, it is a little tricky.
    You must run the previous sections.
    (expecially: e1sl, e1el, e1sc, e1ec, SpatialStep, SizePixel, FolderName, Orientation)

    Then compute the section named 'To see the discretisation'.
    This section is in an 'if' part, put '1==1' if you want to run it, else put '1==0' (it won't help for the latter).
    A figure opens and shows you the discretisation

----------------------------------------------------------------------
Step 6 : Running
----------------------------------------------------------------------

    Check if the sections 'Show the picture and select the extracted zone' and 'To see the discretisation' are well set with 'if 1==0'
    (you do not want to run those parts, it was preliminary work)

    Run
    On the Command Window, 2 lines appear
    the first one is about the iteration on time
    the second one is about the iteration on space for each time (in percentage)

    Comment : If the result is not good, it may maybe because of the SearchZone
    You can go in 'Displacement2D.m' function, and change the value of SZls,SZle,SZcs,SZce
        SZls : Search Zone Line Start
        SZle : Search Zone Line End
        SZcs : Search Zone Column Start
        SZce : Search Zone Column End
    The increase of the plate can be computed, you must fix the parameter p2
    in the function 'Displacement2D.m'. If it can be automated it will be nice

    Comment : Data correction is coded but not used in this function

----------------------------------------------------------------------
Step 7 : Save data
----------------------------------------------------------------------

    Save the following data :
        - Displacement
    This is a structure with the discretization following x and y, the displacement following x and y, a returning map and the strain (e11, e12, e22) fields at different time
        - extraction
        - PictureOrientation
        - thalesL
        - TimeStep
        - limit
        - SpatialStep
        - SizePixel

    The data are saved in the folder save with the name you gave.
    Pictures are created in the folder png.

----------------------------------------------------------------------
Step 8 : Post Processing
----------------------------------------------------------------------
    Go to 'PostProcessing.m' Matlab function.
    Fill the Folder and File names. Normally FolderName is 'save' and FileName must end with '.mat'.
    Fill the start time ts and the end time te for the postprocessing.

    A Gaussian profile is interpolated from 3 x/y slices to determine the shear band width.
    Some initial values are needed for this interpolation.
    Please see https://fr.mathworks.com/help/curvefit/gaussian.html
    This documentation will help you to play easily with the parameters and find a good set.
    Once you have it, please fill the parameters InitialParameterX(i,3) and InitialParameterY(i,3).

    The evolution of the shear band is saved and plotted. 
    
    
