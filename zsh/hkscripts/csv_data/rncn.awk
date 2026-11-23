# max/min = 3 3 5 : col-3, 3rd, around 5
BEGIN{
  FS=OFS=",";split(frame_rows,rows,",");split(frame_cols,cols,",")
  if(length(max)>0){split(max,max_min,",");flag="max"}
  if(length(min)>0){split(min,max_min,",");flag="min"}
  if(dir=="r1c1" || dir=="r1c2"){
  # +1 for skip header
    for(i=1;i<=length(rows);i++)rows_index[rows[i]+1]=1
  }else{
  # r2c1,r2c2
    if(rows[1]>0){
      start_r=rows[1]
    }else if(rows[1]<0){
      start_r=row_lines+rows[1]+1
    }else{
      print "Error inside : syntax, 0 is undefiend behavior"; exit 2
    }
    if(rows[2]>0){
      end_r=rows[2]
    }else if(rows[2]<0){
      end_r=row_lines+rows[2]+1
    }else{
      print "Error inside : syntax, 0 is undefiend behavior"; exit 2
    }
  }
  # skip the header
  for(i=start_r+1;i<=end_r;i++)rows_index[i]=1
  # --- test
  # print "start_r",start_r,"end_r",end_r
  # --- test
 }
NR==1{split($0,header,",")
  if(dir=="r1c2" || dir=="r2c2"){
      if(cols[1]>0){
        start_c=cols[1]
      }else if(cols[1]<0){
        start_c=NF+cols[1]+1
      }else{
        print "Error inside : syntax, 0 is undefiend behavior"; exit 2
      }
      if(cols[2]>0){
        end_c=cols[2]
      }else if(cols[2]<0){
        end_c=NF+cols[2]+1
      }else{
        print "Error inside : syntax, 0 is undefiend behavior"; exit 2
      }
  }
}

NR in rows_index{
  indices[++n]=n
  if(flag=="max" || flag == "min")values[n]=$max_min[1]
  data[n]=data[n] sprintf("%s,%s,",n,NR) 
  if(dir=="r1c1" || dir=="r2c1"){
    for(i=1;i<length(cols);i++)data[n]=data[n] sprintf("%s,",$(cols[i]))
    data[n]=data[n] sprintf("%s",$(cols[length(cols)]))
    }
  else if(dir=="r1c2" || dir=="r2c2"){
    for(i=start_c;i<end_c;i++)data[n]=data[n] sprintf("%s,",$i)
    data[n]=data[n] sprintf("%s",$end_c)
    }
}

END{
# sort
# ascending
# n = 3
# values : [1:10,2:5,3:7] -> [1:5,2;7,3:10]
# indices : [1:1,2:2,3:3]  -> [1:2,2:3,3:1]
indices_lbound=1
indices_ubound=n
if(flag=="min" || flag == "max"){
  if(min_max[2]>n){printf "Error: in min/max sort, datanumber(%i) < min/max second arg (%i)", n, max_min[2]; exit(2)}
  for(j=2;j<=n;j++){
    tmp=values[j]
    tmp_i=indices[j]
    k = j-1
    while(k>0 && values[k]>tmp){
      values[k+1]=values[k]
      indices[k+1]=indices[k]
      k--
      }
    values[k+1] = tmp
    indices[k+1] = tmp_i
  }
  # min/max
  if(flag=="min"){
   index_maxmin=indices[max_min[2]]
   printf "# Check No.%s Min of %s = %s\n",max_min[2],header[max_min[1]],values[max_min[2]]
  }
  if(flag=="max") {
   index_maxmin=indices[n+1-max_min[2]]
   # check
   # print  "index_maxmin:" index_maxmin
   # print "n" n
   # print "values[n],values[n-1]",values[n],values[n-1]
   # check
   printf "# Check No.%s Max of %s = %s\n",max_min[2],header[max_min[1]],values[n+1-max_min[2]]
  }
# n = 3
# values : [1:10,2:5,3:7] -> [1:5,2;7,3:10]
# indices : [1:1,2:2,3:3]  -> [1:2,2:3,3:1]
# min = 2 -> index 3
  indices_ubound = (index_maxmin + max_min[3]) > n ? n : (index_maxmin+max_min[3])
  indices_lbound = (index_maxmin - max_min[3]) < 1 ? 1 : (index_maxmin-max_min[3])
  # print "index_maxmin: " index_maxmin
  # print "indices_lbound: " indices_lbound
  # print "indices_ubound: " indices_ubound
}

if(dir=="r1c1" || dir=="r2c1"){
  printf "Index,Line,";for(i=1;i<length(cols);i++)printf "%s,",header[cols[i]];print header[cols[length(cols)]]
}else if(dir=="r1c2" || dir=="r2c2"){
  printf "Index,Line,";for(i=start_c;i<end_c;i++)printf "%s,",header[i];print header[end_c]
}
# print "n=" n
# for(j=1;j<=n;j++){
for(j=indices_lbound;j<=indices_ubound;j++){
  print data[j]
}
  # print data[1]
}

