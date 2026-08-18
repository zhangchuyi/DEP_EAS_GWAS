i=85
n=3
for name in `cat name.txt`
do
        sort -gk 7 $name.meta > sorted_$name.meta
        sed -i -e '/NA/d' sorted_$name.meta
        awk -v N=$n '{if(NR == 1 || $6 >= N)print $0}' sorted_$name.meta | awk -v I=$i '{if(NR == 1 || $12 > I)print $1,$2,$3,$4,$5,$6,$8,$10,$12}' > sorted_$name.I2_$i.RandomModel.meta
        awk -v N=$n '{if(NR == 1 || $6 >= N)print $0}' sorted_$name.meta | awk -v I=$i '{if(NR == 1 || $12 < I || $12 == I)print $1,$2,$3,$4,$5,$6,$7,$9,$12}' > sorted_$name.I2_$i.FixedModel.meta
        sed -i '1d' sorted_$name.I2_$i.RandomModel.meta
        cat sorted_$name.I2_$i.FixedModel.meta  sorted_$name.I2_$i.RandomModel.meta > sorted_$name.Diff-Model.I$i.meta
        awk 'NR == 1 || $8 != 1' sorted_$name.Diff-Model.I$i.meta > sorted_$name.Diff-Model.I$i.meta.tmp
        mv sorted_$name.Diff-Model.I$i.meta.tmp sorted_$name.Diff-Model.I$i.meta
done
