


reg   az F518_SUF c.zpalter i.S1
est store m1



logit mig01 F518_SUF c.zpalter##i.S1
est store m2

esttab m1 m2

est drop _all

