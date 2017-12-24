Simple GUI example
=========================================
This will guide you step by step in processing a sample quantitative MRI dataset with the graphical user interface. For this example, a variable flip angle (VFA) T\ :sub:`1`\  mapping brain dataset will be used.

1. Open MATLAB
----------------------------------
Open the directory where qMRLab was installed.

2. Run startup
----------------------------------
This will setup your path ::

	startup

3. Download example data
------------------------------
Variable flip angle (VFA) data is used to compute a T\ :sub:`1`\  map. The main input data is stored as a 4D volume, where the 4th dimension are acquisitions are different flip angles. 
For example, in this test dataset, 1 slice at 2 different flip angles were acquired: volume 1 was FA = 3 deg and volume 2 was FA = 20deg, such that *VFAData.nii.gz* is 128x128x1x2. The other optional inputs are a *Mask.nii.gz* and a *B1Map.nii.gz*, and are included in this example.

To download the demo data, run the following commands in the MATLAB terminal::

	Model=vfa_t1;
	downloadData(Model)

When prompted, select a folder where you would like to put the sample data .

4. Launch the GUI
-----------------------------
Type this is MATLAB to launch the main GUI (graphical user interface)::

	qMRLab

5. Model Selection
-------------------------
On the top left-hand side pull-down menu, select the quantitative MRI method you wish to use, which in this in this is case is *vfa_t1        (T1_relaxometry/)* :

.. figure:: _static/method-select.png
   :scale: 45 %

At any time, you may use the *Help* button in the *Options* panel to get a description of the model:

.. figure:: _static/help.png
   :scale: 45 %

For the list of available models, please check :ref:`Methods available`.

6. Load the data
--------------------------
Load the raw data in qMRLab by selecting *Browse* next to *Work Dir*. Select the folder where you have previously saved the sample data (this will load all the data into the correct locations automatically):

.. figure:: _static/load-data.png
   :scale: 45 %

Please note that the data were loaded automatically because they were named following the naming convention for that model and were contained within the working directory. In the future, if your data follows a different naming convention, you may simply load the data volumes one by one after selecting your working directory. In both these cases, your working directory is also the directory were all processed files (e.g.) will be placed.

For a more detailed description of what the input data should look like, please refer to :ref:`3.1	Data format`

7. View the data
-------------------------
You can look at your data by clicking *View* next to the name of the file:

.. figure:: _static/view-data.png
   :scale: 45 %

You can browse through slices or volumes of the data files by using the sliding bars on the left-hand side of the image.

8. Set up the protocol
------------------------
For this dataset, the protocol will be set up by default with the flip angles and TRs: 


.. figure:: _static/protocol.png
   :scale: 55 %

For your own acquisition, you will have to use an external txt file to load the parameters, please refer to :ref:`5.1 Protocol`. 

9. View the data fit in 1 voxel
-----------------------------------

Before fitting the whole volume, it's a good idea to take a look at your data and how it fits the model. Here, we can visualize the fit in 1 voxel at a time. In the *Cursor* section, press *Select*. Then select a voxel in the image and the press *View data fit*:

.. figure:: _static/select-vox.png
   :scale: 45 %

A new window will pop-up with the results of the fit in that voxel:

.. figure:: _static/fit.png
   :scale: 30 %


10. Fit the whole dataset
---------------------------
We can now fit the whole volume by pressing the large *Fit Data* button.

.. figure:: _static/fit-data.png
   :scale: 45 %

A wait bar will appear while the data is being processed and will automatically when done. From the pull-down menu to the left of the image, it's possible to select the output you would like to view. For example, the T1map:

.. figure:: _static/view-fit.png
   :scale: 55 %

The fitted T\ :sub:`1`\  and M\ :sub:`0`\  maps are saved locally in the FitResults/ folder within your working directory (as both a single *.mat MATLAB filetype and separate *.nii.gz (compressed NIfTI files) filetypes).

For more information and to explore other functionality such as the simulations, please visit :ref:`Graphical User Interface Usage`.
