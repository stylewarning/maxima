# Lisp-Based Installation

Maxima can be built using a purely Lisp-based procedure. This
procedure is not yet as polished as the GNU Autotools system described
in the file `INSTALL`. However, it may be more convenient on a system
(e.g., Windows) which does not have the GNU Autotools installed.

User feedback on this procedure would be greatly appreciated.

Note: xmaxima cannot be built using this procedure.

Note (2): Plotting on Windows does not (yet) work using this procedure.

## Part 0: Common Lisp and Maxima

Make sure you have an implementation of ANSI Common Lisp
installed. SBCL is a popular choice.

If you're reading this document, you've probably obtained a copy of
the Maxima source code. If not, run the command

```
git clone git://git.code.sf.net/p/maxima/code maxima
```

## Part 1: Configuration

The first step is to prepare Maxima to be built.

1. Change to the top-level Maxima directory (i.e., the directory which
   contains `src/`, `tests/`, `share/`, and other directories).

2. Launch your Lisp implementation.

3. Load the file `configure.lisp`:

   ```
   (load "configure.lisp")
   ```

4. Generate configuration files:

   ```
   (maxima-configure:configure)
   ```

   You will be prompted for several inputs. Pressing return without
   input will accept the default values.

   The configure process can be automated through the use of keyword
   arguments to configure. For example,

   ```
   (maxima-configure:configure :interactive nil)
    ```

   will use the default values for all options and will not prompt
   for any input.

   See the file `configure.lisp` for more details.

5. Quit Lisp by Ctrl+D or `(uiop:quit)` and change to the `src/`
   directory.

### Additional steps with GCL

If you're using the GCL implementation of Lisp, then follow the
additional instructions:

1. (GCL only:) Create these directories if they do not already exist:

   ```
   binary-gcl
   binary-gcl/numerical
   binary-gcl/numerical/slatec
   ```

2. (GCL only:) Create an empty `sys-proclaim.lisp` file, restart Lisp
   and do:

   ```
   (load "generate-sys-proclaim.lisp")
   ```

   Delete the directory `binary-gcl` and repeat the previous before
   continuing.

## Part 2: Build

Maxima builds with defsystem. The file `maxima-build.lisp` is provided
for rudimentary guidance in using defsystem. Experts should feel free
to substitute their knowledge of defsystem for the following steps.

1. Restart Lisp, and load `maxima-build.lisp`:

   ```
   (load "maxima-build.lisp")
   ```

2. Compile the Lisp source code:

   ```
   (maxima-build:compile-maxima)
   ```

3. Quit and restart Lisp.

4. Load the compiled Lisp files:

   ```
   (load "maxima-build.lisp")
   (maxima-build:load-maxima)
   ```

5. (Optional:) At this point, Maxima is able to be run within a Lisp session.

   ```
   (cl-user::run)
   ```

   That should bring up the Maxima input prompt.

6. Despite being able to run Maxima, we still want to build a Maxima
   binary. Due to the way some Lisp implementations work, the binary
   is usually not an executable, but rather an "image" which a Lisp
   implementation can immediately load and run.

   In order to save a binary, enter the following at the Lisp input
   prompt:

   ```
   (maxima-build:save-maxima-image)
   ```

   At present it works for Clisp, SBCL, GCL, CMUCL, Scieneer, Allegro
   and CCL.  Reinhard Oldenburg writes, in reference to Lispworks:
   "(maxima-dump) works when threading is disabled."  Some Lisp
   implementations (SBCL, GCL, CMUCL, Scieneer, maybe others)
   terminate after saving the binary.

## Part 3: Running Maxima

Now you should have a Maxima!

### Executing Maxima and running the tests

Each Lisp implementation allows one to specify the name of the image
to be executed in a slightly different way. Two scripts, maxima and
maxima.bat, are provided to specify the command line options
appropriately.

On UNIX systems and Windows with Bourne shell:

```
sh maxima
```

or

```
chmod a+x maxima
./maxima
```

Even if Bourne shell is not available on your system, it is worth
looking at the way images are invoked at the end of the script.

On Windows without Bourne shell:

```
maxima.bat
```

If this works, you can test the build. At the Maxima prompt, enter:

```
run_testsuite();
```
