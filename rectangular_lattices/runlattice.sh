#!/bin/bash
inputs=$1
coefs=$2
vecs=$3
calcname=$4
runtype=$5
sgnum=$6
g=$7

export OPENBLAS_NUM_THREADS=1
IFS=$'\n';

export calcname
echo "calcname is: $calcname"
mpb ${inputs} ${coefs} ${vecs} rvecs="(list (vector3 1 0) (vector3 0.5 0.8))" prefix="\"$calcname\"" nbands=10 \
fourier-lattice.ctl 2>&1 | tee logs/${calcname}.log
unset IFS;
#runtype=$(grep "run-type=" input/${calcname}.sh | sed 's/run-type=//;s/\"//g') # get polarization-string
cat logs/${calcname}.log | . get-freqs.sh $runtype ${calcname}-dispersion.out
cat logs/${calcname}.log | . get-symeigs.sh ${calcname}-symeigs.out

mv "$calcname-epsilon.h5" ./output/sg${sgnum}/g${g}/${runtype}/${calcname}-epsilon.h5
mv ./output/${calcname}-symeigs.out ./output/sg${sgnum}/g${g}/${runtype}/${calcname}-symeigs.out
mv ./output/${calcname}-dispersion.out ./output/sg${sgnum}/g${g}/${runtype}/${calcname}-dispersion.out
