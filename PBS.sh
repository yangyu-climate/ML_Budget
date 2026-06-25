rm -rf running.log
rm -rf running.err
#nohup matlab -nodisplay -nosplash -nodesktop < Run.m 1>running.log 2>running.err &
srun -N 1 -n 1 --mem=160G --time=30-00:00:00 --qos unlim matlab -nodisplay -nosplash -nodesktop < Run.m 1>running.log 2>running.err &
