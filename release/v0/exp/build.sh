#!/bin/ksh

set -e

# DEBUG switch on (1) or off (0)
CLEAN=1
# DEBUG switch on (1) or off (0)
DEBUG=0
# OPENMP switch on (1) or off (0)
OPENMP=1

# List of valid/tested machines
valid_machines=(hera orion cheyenne macosx linux wcoss_cray wcoss_phase1 wcoss_phase2 jet gaea orion)
valid_compilers=(intel pgi gnu)

function usage   {
  echo " "
  echo "Usage: "
  echo "build.sh machine compiler homedir"
  echo "    Where: machine  [required] can be : ${valid_machines[@]}"
  echo "           compiler [required] can be : ${valid_compilers[@]}"
  echo "                                        (wcoss, jet, gaea: intel only)"
  echo "           homedir  [optional] can be any valid directory with write permissions"
  echo " "
  echo "Further compile options are set at the top of build.sh: CLEAN, DEBUG, OPENMP"
  echo " "
  exit 1
}

if [[ $1 = "help" ]] ; then usage; fi

# Always specify host and compiler
if [[ $# -lt 2 ]];  then usage; fi
machine=${1}
compiler=${2}
if [[ ${machine} == hera || ${machine} == orion || ${machine} == cheyenne || ${machine} == macosx || ${machine} == linux || ${machine} == orion ]]; then
  arch=${machine}.${compiler}
elif [[ ${machine} == wcoss_cray || ${machine} == wcoss_phase1 || ${machine} == wcoss_phase2 || ${machine} == jet || ${machine} == gaea ]]; then
  if [[ ${compiler} == intel ]]; then
    arch=${machine}
  else
    usage
  fi
fi

set -x

homedir=${3:-`pwd`/../../..}

# Build the various FV3 binaries
cd $homedir/tests
# Set debug flag
if [ "$DEBUG" -eq 1 ]; then
  debug_compile_option="DEBUG=Y"
  mode="debug"
else
  debug_compile_option="DEBUG=N"
  mode="prod"
fi
# Set OpenMP flag
if [ "$OPENMP" -eq 1 ]; then
  openmp_compile_option="OPENMP=Y"
else
  openmp_compile_option="OPENMP=N"
fi

# set other options

 extra_options=""

#ccpp_option="CCPP=Y HYBRID=N STATIC=Y SUITES=FV3_GFS_2017_fv3wam"; mode=$mode"ccpp"
#extra_options=$extra_options" "$ccpp_option

 multi_gases_option="MULTI_GASES=Y" ; mode=$mode"MG"
 extra_options=$extra_options" "$multi_gases_option

 molecular_diffusion_option="MOLECULAR_DIFFUSION=Y" ; mode=$mode"MD"
 extra_options=$extra_options" "$molecular_diffusion_option

 idea_phys_option="IDEA_PHYS=Y" ; mode=$mode"IP"
 extra_options=$extra_options" "$idea_phys_option

#deep_atmos_option="DEEP_ATMOS_DYNAMICS=Y" ; mode=$mode"DD"
#extra_options=$extra_options" "$deep_atmos_option

#idea_conv_adj_option="IDEA_CONV_ADJ=Y" ; mode=$mode"CA"
#extra_options=$extra_options" "$idea_conv_adj_option

 echo $extra_options
 echo $mode

# 32-bit non-hydrostatic
#precision_option="32BIT=Y"
#precision="32bit"
#hydro_option="HYDRO=N"
#hydro="nh"
#compile_option="$debug_compile_option $openmp_compile_option $hydro_option $precision_option $extra_options "
#./compile.sh $homedir/FV3 $arch "$compile_option" 1 YES NO
#cp $homedir/tests/fv3_1.exe ../NEMS/exe/fv3_gfs_${hydro}.${mode}.${precision}.${compiler}.x
#rm $homedir/tests/fv3_1.exe

# 32-bit hydrostatic
#precision_option="32BIT=Y"
#precision="32bit"
#hydro_option="HYDRO=Y"
#hydro="hydro"
#compile_option="$debug_compile_option $openmp_compile_option $hydro_option $precision_option $extra_options "
#./compile.sh $homedir/FV3 $arch "$compile_option" 1 YES NO
#cp $homedir/tests/fv3_1.exe ../NEMS/exe/fv3_gfs_${hydro}.${mode}.${precision}.${compiler}.x
#rm $homedir/tests/fv3_1.exe

# 64-bit non-hydrostatic
 precision_option="32BIT=N"
 precision="64bit"
 hydro_option="HYDRO=N"
 hydro="nh"
 compile_option="$debug_compile_option $openmp_compile_option $hydro_option $precision_option $extra_options "
 ./compile.sh $homedir/FV3 $arch "$compile_option" 1 YES YES
 cp $homedir/tests/fv3_1.exe ../NEMS/exe/fv3_gfs_${hydro}.${mode}.${precision}.${compiler}.x
 rm $homedir/tests/fv3_1.exe

# 64-bit hydrostatic
#precision_option="32BIT=N"
#precision="64bit"
#hydro_option="HYDRO=Y"
#hydro="hydro"
#compile_option="$debug_compile_option $openmp_compile_option $hydro_option $precision_option $extra_options "
#./compile.sh $homedir/FV3 $arch "$compile_option" 1 YES NO
#cp $homedir/tests/fv3_1.exe ../NEMS/exe/fv3_gfs_${hydro}.${mode}.${precision}.${compiler}.x
#rm $homedir/tests/fv3_1.exe
