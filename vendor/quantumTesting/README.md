# Quantum Testing Framework
You'll likely want to create a virtual environment for the packages. See instructions here on creating, activating, and deactivating the virtual environment: https://docs.python.org/3/library/venv.html

As of now these are the packages to include in the venv:\
antlr4-python3-runtime 4.9.2\
dill                   0.4.0\
exceptiongroup         1.3.0\
graphviz               0.21\
hypothesis             6.145.1\
numpy                  2.2.6\
pip                    25.3\
qiskit                 2.2.1\
rustworkx              0.17.1\
scipy                  1.15.3\
setuptools             57.4.0\
sortedcontainers       2.4.0\
stevedore              5.5.0\
typing_extensions      4.15.0\

Once you have the virtual enrionment set up, you can run the files in `qiskit-to-xmlprogrammer` with `python3 qiskit-to-xmlprogrammer/example_circuits.py` and similar commands for library_circuits.py and qiskit_to_xmlprogrammer.py\
We are currently working on getting two test files in `xml_benchmarks` running; you can run them with `python3 xml_benchmarks/test_cl_adder_property.py`
and `python3 xml_benchmarks/test_rz_adder_property.py` although they currently resuslt in Python errors
