# -*-mode: tcl; fill-column: 75; tab-width: 8; coding: iso-latin-1-unix -*-
#
#       $Id: Paths.tcl,v 1.12 2004-07-04 03:30:35 billingd Exp $
#
# Attach this near the bottom of the xmaxima code to find the paths needed
# to start up the interface.

proc setMaxDir {} {
    global env maxima_priv autoconf tcl_platform

    if {$tcl_platform(platform) == "windows"} {
	# Assume the executable is one level down from the top
	# for 5.6 this was src/ and for 5.9 its bin/
	set up [file dir [file dir [info name]]]

	if {[info exists autoconf] && \
		[info exists autoconf(prefix)] && \
		[info exists autoconf(exec_prefix)] && \
		[info exists autoconf(libdir)] && \
		[info exists autoconf(libexecdir)] && \
		[info exists autoconf(datadir)] && \
		[info exists autoconf(infodir)] && \
		[info exists autoconf(version)] && \
		[info exists autoconf(package)] && \
		[file isdir  $autoconf(datadir)] && \
		[file isdir \
		     [file join $autoconf(datadir) \
			  $autoconf(package) $autoconf(version)]]} {

	    # Assume it's CYGWIN or  MSYS in /usr/local
	} elseif {[file isdir $up/lib] && \
		      [file isdir $up/bin] && \
		      [file isdir $up/libexec] && \
		      [file isdir $up/info] && \
		      [file isdir $up/share]} {
	    set autoconf(prefix) $up
	    set env(MAXIMA_PREFIX) $up
	    set autoconf(exec_prefix) $up
	    set autoconf(libdir) "$up/lib"
	    set autoconf(libexecdir) "$up/libexec"
	    set autoconf(datadir) "$up/share"
	    set autoconf(infodir) "$up/info"
	    # These two should be valid
	    # set autoconf(package) "maxima"
	    # set autoconf(version) "5.9.0rc1"
	} else {
	    # Old windows 5.5 layout
	    # Assume we are in the same directory as saved_maxima
	    if {[file isfile [set exe $up/src/saved_maxima.exe]]} {

		set env(MAXIMA_DIRECTORY) $up

		set maxima_priv(maxima_verpkgdatadir) \
		    $env(MAXIMA_DIRECTORY)

		set maxima_priv(xmaxima_maxima) $exe

		set maxima_priv(maxima_xmaximadir) [file dir $exe]

		# This should be unused
		set maxima_priv(maxima_verpkglibdir) \
		    $env(MAXIMA_DIRECTORY)

		set maxima_priv(maxima_verpkgdatadir) \
		    $env(MAXIMA_DIRECTORY)

		# This should be unused
		set maxima_priv(maxima_prefix) \
		    $env(MAXIMA_DIRECTORY)
	    }
	}
    }

    #mike Could someone document all of these environment variables?
    # autoconf(prefix) does not seem to me to be the equivalent of
    # $env(MAXIMA_DIRECTORY) so I don't understand the next statement

    # jfa: MAXIMA_PREFIX supersedes MAXIMA_DIRECTORY. (Why? Because the
    #      option to configure is --prefix. MAXIMA_PREFIX is thus a runtime
    #      change of --prefix.)
    #      Yes, MAXIMA_DIRECTORY means the same thing. We only include
    #      it for some level of backward compatibility.
    if { [info exists env(MAXIMA_DIRECTORY)] } {
	set env(MAXIMA_PREFIX) $env(MAXIMA_DIRECTORY)
    }

    # jfa: This whole routine is a disaster. The general plan for maxima
    # paths is as follows:
    #   1) Use the environment variables if they exist.
    #   2) Otherwise, attempt to use the compile-time settings from
    #      autoconf.
    #   3) If the entire package has been moved to a prefix other than
    #      that given at compile time, use the location of the (x)maxima
    #      executable to determine the new prefix.
    # The corresponding path setting procedure in the maxima source can
    # be found in init-cl.lisp.

    # The following section should be considered temporary work-around.
        if { [info exists env(MAXIMA_VERPKGDATADIR)] } {
	set maxima_priv(maxima_verpkgdatadir) $env(MAXIMA_VERPKGDATADIR)
    }
    # End temporary workaround. It's only a workaround because the next
    # section is backwards: 
    

    #mike Is it correct to assume that autoconf exists and is valid
    # for binary windows distributions? I think it would be better
    # to make (MAXIMA_DIRECTORY) take precedence, and work off
    # [info nameofexe] if necessary.

    if {[info exists maxima_priv(maxima_prefix)]} {
	# drop through
    } elseif { [info exists env(MAXIMA_PREFIX)] } {
	set maxima_priv(maxima_prefix) $env(MAXIMA_PREFIX)
    } else {
	set maxima_priv(maxima_prefix) $autoconf(prefix)
    }

    if {[info exists maxima_priv(maxima_verpkgdatadir)]} {
	# drop through
    } else {
	if { [info exists env(MAXIMA_DATADIR)] } {
	    set maxima_datadir $env(MAXIMA_DATADIR)
	} elseif { [info exists env(MAXIMA_PREFIX)] } {
	    set maxima_datadir \
		[file join $env(MAXIMA_PREFIX) share]
	} else {
	    set maxima_datadir $autoconf(datadir)
	}
	# maxima_datadir is unused outside of this proc

	if {![file isdir $maxima_datadir]} {
	    tide_notify [M "Maxima data directory not found in '%s'" \
			     [file native  $maxima_datadir]]
	}

	set maxima_priv(maxima_verpkgdatadir) \
	    [file join $maxima_datadir $autoconf(package) \
		 $autoconf(version)]
    }


    if {[info exists maxima_priv(maxima_verpkglibdir)]} {
	# drop through
    } elseif { [info exists env(MAXIMA_VERPKGLIBDIR)] } {
	set maxima_priv(maxima_verpkglibdir) $env(MAXIMA_VERPKGLIBDIR)
    } elseif { [info exists env(MAXIMA_PREFIX)] } {
	set maxima_priv(maxima_verpkglibdir) \
	    [file join $env(MAXIMA_PREFIX) lib $autoconf(package) \
		 $autoconf(version)]
    } else {
	set maxima_priv(maxima_verpkglibdir) \
	    [file join $autoconf(libdir) $autoconf(package) \
		 $autoconf(version)]
    }

    if {[info exists maxima_priv(maxima_xmaximadir)]} {
	# drop through
    } elseif { [info exists env(MAXIMA_XMAXIMADIR)] } {
	set maxima_priv(maxima_xmaximadir) $env(MAXIMA_XMAXIMADIR)
    } else {
	set maxima_priv(maxima_xmaximadir) \
	    [file join $maxima_priv(maxima_verpkgdatadir) xmaxima]
    }

    # Bring derived quantities up here too so we can see the
    # side effects of setting the above variables

    # used in Menu.tcl CMMenu.tcl
    if {[file isdir [set dir [file join  $maxima_priv(maxima_verpkgdatadir) info]]]} {
	# 5.6 and down
	set maxima_priv(pReferenceToc) \
	    [file join $dir maxima_toc.html]
    } elseif {[file isdir [set dir [file join  $maxima_priv(maxima_verpkgdatadir) doc]]]} {
	# 5.9 and up
	set maxima_priv(pReferenceToc) \
	    [file join $dir html maxima_toc.html]
    } else {
	tide_notify [M "Documentation not found in '%s'" \
			 [file native  $maxima_priv(maxima_verpkgdatadir)]]
    }

    # used in Menu.tcl CMMenu.tcl
    if {[file isdir [set dir [file join  $maxima_priv(maxima_verpkgdatadir) tests]]]} {
	# 5.9 and up
	set maxima_priv(pTestsDir) $dir
    } elseif {[file isdir [set dir [file join  $maxima_priv(maxima_verpkgdatadir) doc]]]} {
	# 5.6 and down
	set maxima_priv(pTestsDir) $dir
    } else {
	# who cares
    }


    set file [file join $maxima_priv(maxima_xmaximadir) "intro.html"]

    if {![file isfile $file]} {
	tide_notify [M "Starting documentation not found in '%s'" \
			 [file native	$file]]

	set maxima_priv(firstUrl) ""
    } else {
	if {$tcl_platform(platform) == "windows"} {
	    set file [file attrib $file -shortname]
	    # convert to unix
	    set file [file dir $file]/[file tail $file]
	}
	# FIXME: This is bogus - need a FileToUrl
	set maxima_priv(firstUrl) file:/$file
    }

    # set up for autoloading
    global auto_path
    set dir [file join $maxima_priv(maxima_xmaximadir) Tkmaxima]
    if {[file isdir $dir]} {
	lappend auto_path $dir
    }

    # jfa: Windows 98 users were seeing long startup times because
    # MAXIMA_USERDIR defaults to HOME, which is usually C:\.
    # Make the default something else under Windows 98 as a workaround.
    # This is ugly.
    if {$tcl_platform(os) == "Windows 95"} {
	if {![info exists env(MAXIMA_USERDIR)]} {
	    set env(MAXIMA_USERDIR) "$maxima_priv(maxima_prefix)/user"
	}
    }
}

proc vMAXSetMaximaCommand {} {
    global maxima_priv tcl_platform env

    set maxima_opts [lMaxInitSetOpts]
    set maxima_priv(localMaximaServer) ""

    if {[info exists maxima_priv(xmaxima_maxima)] && \
	    $maxima_priv(xmaxima_maxima) != ""} {
	if {[set exe [auto_execok $maxima_priv(xmaxima_maxima)]] == "" } {

	    tide_failure [M "Error: Maxima executable not found\n%s\n\n Try setting the environment variable  XMAXIMA_MAXIMA." \
			      [file native $maxima_priv(xmaxima_maxima)]]
	    return
	}
    } elseif { [info exists env(XMAXIMA_MAXIMA)] } {
	set maxima_priv(xmaxima_maxima) $env(XMAXIMA_MAXIMA)
	if {[set exe [auto_execok $maxima_priv(xmaxima_maxima)]] == "" } {
	    tide_failure [M "Error. maxima executable not found.\n%s\nXMAXIMA_MAXIMA=$env(XMAXIMA_MAXIMA)" \
			      [file native $maxima_priv(xmaxima_maxima)]]
	    return
	}
    } else {
	set maxima_priv(xmaxima_maxima) maxima
	if {[set exe [auto_execok $maxima_priv(xmaxima_maxima)]] == "" } {
	    tide_failure [M "Error: Maxima executable not found\n\n Try setting the environment variable  XMAXIMA_MAXIMA."]
	}

	set maxima_priv(xmaxima_maxima) maxima
	if {[set exe [auto_execok $maxima_priv(xmaxima_maxima)]] == "" } {
	    tide_failure [M "Error: Maxima executable not found\n\n Try setting the environment variable  XMAXIMA_MAXIMA."]
	}
    }

    # FIXME: More gruesome windows hacks.  db: 2004-07-02
    # Q. What if there is a space in the path component of exe? 
    # A. Convert it to a shortname.
    # Q. Why does that fail?
    # A. The name is surrounded by {}.  Just rip these out. Yuk
    if {$tcl_platform(platform) == "windows"} {
	if {[string first " " $exe] >= 0} {
            regsub -all "\[\{\}\]" $exe "" exe
            set exe [file attrib $exe -shortname]
        }
    }
    set command {}
    lappend command $exe
    eval lappend command  $maxima_opts


    # vvz: Windows NT/2000/XP
    # db:  All windows now
    if {$tcl_platform(platform) == "windows"} {
	lappend command -s PORT
    # vvz: Unix. Should be as above but we need this due to
    # weird behaviour with some lisps - Why?
    } else {
          lappend command -r ":lisp (start-server PORT)"
    }

    lappend command &
    set maxima_priv(localMaximaServer) $command
	

}
