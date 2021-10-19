Fortran `curfit` use instructions (from code)

Given the set of data points (x(i),y(i)) and the set of positive numbers w(i),i=1,2,...,m,subroutine curfit determines a smooth spline approximation of degree k on the interval xb <= x <= xe.

If `iopt=-1` curfit calculates the weighted least-squares spline according to a given set of knots.

If `iopt>=0` the number of knots of the spline s(x) and the position t(j),j=1,2,...,n is chosen automatically by the routine. 

The smoothness of *s(x)* is then achieved by minimization the discontinuity jumps of the k<sup>th</sup> derivative of *s(x)* at the knots *t(j),j=k+2,k+3,..., n-k-1*. 
The amount of smoothness is determined by the condition that *f(p)=sum((w(i)*(y(i)-s(x(i))))**2) <= s*, with s a given non-negative constant, called the smoothing factor.

The fit s(x) is given in the b-spline representation (b-spline coefficients c(j),j=1,2,...,n-k-1) and can be evaluated by means of subroutine `splev`.

Calling sequence:
```fortran
   call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,wrk,
  * lwrk,iwrk,ier)
```

| P        | type              | I/O | description |
| ---------|-------------------|-----|-------------|
| `iopt`   | \*const i32       | I   | On entry `iopt` must specify whether a weighted least-squares spline (`iopt`=-1) or a smoothing spline (`iopt`= 0 or 1) must be determined.  If `iopt`=0 the routine will start with an initial set of knots `t(i)`=`xb`, `t(i+k+1)`=`xe`, i=1,2,...  k+1. If `iopt=1` the routine will continue with the knots found at the last call of the routine Attention: a call with `iopt`=1 must always be immediately preceded by another call with `iopt`=1 or `iopt=0`|
| `m`      | \*const i32       | I   | On entry m must specify the number of data points.  `m > k` |
| `x`      | \*const Vec\<f64\>| I   | Array of dimension at least (m). Before entry, x(i) must be set to the i<sup>th</sup> value of the independent variable x, for i=1,2,...,m. these values must be supplied in strictly ascending order.|
| `y`      | \*const Vec\<f64\>| I   | Array of dimension at least (m). Before entry, y(i) must be set to the i<sup>th</sup> value of the dependent variable y, for i=1,2,...,m.|
| `w`      | \*const Vec\<f64\>| I   | Array of dimension at least (m). Before entry, w(i) must be set to the i<sup>th</sup> value in the set of weights. The w(i) must be strictly positive.|
| `xb`,`xe`| \*const f64       | I   | On entry `xb` and `xe` must specify the boundaries of the approximation interval. `xb<=x(1)`, `xe>=x(m)`.|
| `k`      | \*const i32       | I   | On entry `k` must specify the degree of the spline.  1<=k<=5. It is recommended to use cubic splines (k=3).  The user is strongly dissuaded from choosing k even,together with a small s-value.|
| `s`      | \*const f64       | I   | On entry (in case `iopt>=0`) s must specify the smoothing factor. s >=0. For advice on the choice of s see further comments.|
| `nest`   | \*const i32       | I   | On entry nest must contain an over-estimate of the total number of knots of the spline returned, to indicate the storage space available to the routine. nest >=2*k+2.  in most practical situation nest=m/2 will be sufficient.  always large enough is  nest=m+k+1, the number of knots needed for interpolation (s=0).|
| `n`      | \*mut i32         | IO  | Unless `ier` =10 (in case `iopt` >=0), n will contain the total number of knots of the spline approximation returned.  If the computation mode `iopt=1` is used this value of n should be left unchanged between subsequent calls.  In case `iopt=-1`, the value of n must be specified on entry.|
| `t`      | \*mut Vec\<f64\>  | IO  | Array of dimension at least (nest).  On successful exit, this array will contain the knots of the spline,i.e. the position of the interior knots t(k+2),t(k+3) ...,t(n-k-1) as well as the position of the additional knots *t(1)=t(2)=...=t(k+1)=xb* and *t(n-k)=...=t(n)=xe* needed for the b-spline representation.  If the computation mode `iopt=1` is used, the values of t(1), t(2),...,t(n) should be left unchanged between subsequent calls. if the computation mode `iopt=-1` is used, the values *t(k+2),...,t(n-k-1)* must be supplied by the user, before entry. see also the restrictions (`ier=10`).|
| `c`      | \*mut Vec\<f64\>  | O   | Array of dimension at least (nest).  On successful exit, this array will contain the coefficients c(1),c(2),..,c(n-k-1) in the b-spline representation of s(x)|
| `fp`     | \*mut Vec\<f64\>  | O   | Unless `ier`=10, `fp` contains the weighted sum of squared residuals of the spline approximation returned.|
| `wrk`    | \*mut Vec\<f64\>  | IO  | Array of dimension at least (`m*(k+1)+nest*(7+3*k)`).  Used as working space. If the computation mode `iopt`=1 is used, the values `wrk(1)`,...,`wrk(n)` should be left unchanged between subsequent calls.|
| `lwrk`   | \*const i32       | I   | On entry,`lwrk` must specify the actual dimension of the array wrk as declared in the calling (sub)program. `lwrk` must not be too small (see `wrk`).|
| `iwrk`   | \*mut Vec\<i32\>  | IO  | Array of dimension at least (nest).  Used as working space. If the computation mode `iopt`=1 is used,the values `iwrk(1)`,...,`iwrk(n)` should be left unchanged between subsequent calls.|
| `ier`    | \*mut i32         | IO  | Unless the routine detects an error, `ier` contains a non-positive value on exit|
