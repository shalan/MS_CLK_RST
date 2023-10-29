Using the Makefile for Compilation and Simulation
===============================================

This Makefile provides a convenient way to perform various tasks related to compilation and simulation of RTL (Register Transfer Level) designs.

Compiling RTL
-------------

To compile RTL code, simply run:

.. code-block:: bash

   make rtl

This command compiles the RTL sources.

Compiling Gate-Level (GL) Simulation
-------------------------------------

For gate-level (GL) simulation, use:

.. code-block:: bash

   make gl

Make sure to set the `PDK_ROOT` and `MGMT_ROOT` environment variables for GL simulation.

Compiling SDF Simulation
------------------------

Compile for SDF simulation with:

.. code-block:: bash

   make sdf

Ensure that the `PDK_ROOT` and `MGMT_ROOT` environment variables are correctly set for SDF simulation.

Changing Simulation Corner
--------------------------

To change the simulation corner from the default `nom-Typical`, use the `CORNER` variable. For example:

.. code-block:: bash

    CORNER=nom-Fastest make sdf

You can choose from options like:
- `nom-Fastest`
- `nom-Slowest`
- `min-Typical`
- And so on...

Cleaning Up
-----------

To clean the directory from compiled files and artifacts, run:

.. code-block:: bash

   make clean

This Makefile streamlines the process of compiling and simulating RTL, gate-level, and SDF designs. It offers flexibility to change simulation corners and provides an easy way to clean up generated files. Please ensure that you've properly configured the environment variables (`PDK_ROOT` and `MGMT_ROOT`) before using this Makefile for GL and SDF simulations.
