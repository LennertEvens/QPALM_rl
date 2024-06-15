# Proximal Augmented Lagrangian method for Quadratic Programs with Reinforcement Learning

This repository is an adaptation of QPALM, a numerical optimization package that finds stationary points of (possibly **nonconvex**) quadratic programs, that is

$$
    \begin{equation}
        \begin{aligned}
            & \underset{x}{\textbf{minimize}}
            & & \tfrac12 x^\top Q x + q^\top x\\
            & \textbf{subject to}
            & & b_\mathrm{min} \le Ax \le b_\mathrm{max} \\
        \end{aligned}
    \end{equation}
$$

The original repository can be found at <https://github.com/kul-optec/QPALM>
In this version, the heuristic update rule for the penalty factors is replaced by a policy trained with reinforcement learning.
## Documentation

The documentation for default QPALM can be found at: <https://kul-optec.github.io/QPALM/Doxygen>  
Examples are included as well: <https://kul-optec.github.io/QPALM/Doxygen/examples.html>

## Installation

Currently, QPALM-RL is only available through the Python interface and can be installed by building from source:
```sh
git clone https://gitlab.esat.kuleuven.be/r0791177/QPALM_rl.git --single-branch --depth 1 --recursive
cd QPALM_rl
pip install -r requirements.txt
pip install . --no-build-isolation
```

## Examples

An example of the use of reinforcement learning has been added in examples/python/.

## License

QPALM is licensed under LGPL v3.0. Some modules are used in this software: 
* LADEL: authored by Ben Hermans and licensed under [LGPL-v3](LICENSE).
* LOBPCG: the version of LOBPCG used here was written by Ben Hermans and licensed under the GNU Lesser General Public License v3.0, see [LOBPCG/LICENSE](https://github.com/Benny44/LOBPCG/blob/master/LICENSE).
* LAPACK: authored by The University of Tennessee and The University of Tennessee Research Foundation, The University of California Berkeley, and The University of Colorado Denver, and licensed under BSD-3, see [here](https://github.com/Reference-LAPACK/lapack/blob/master/LICENSE).
