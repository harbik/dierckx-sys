Instructions and Parameter Descriptions

*The following is directly taken from Paul Dierckx' source code documentation, but adapted for Rust conventions; in particular the array indices where changed, which start at 1 for Fortran, but 0 for Rust.
A few --minor-- edits were made.*

Given the set of data points `(x[i],y[i])` and the set of positive numbers `w[i],i=0,1,...,m-1`,
subroutine curfit determines a smooth spline approximation of degree `k` on the interval `xb<=x<= xe`.

If `iopt=-1` curfit calculates the weighted least-squares spline according to a given set of knots.

If `iopt>=0` the number of knots of the spline `s(x)` and the position `t[j],j=0,1,...,n-1` is chosen automatically by the routine. 

The smoothness of `s(x)` is then achieved by minimization the discontinuity jumps of the k<sup>th</sup> derivative of *s(x)* at the knots `t[j],j=k+1,k+2,..., n-k-2`. 
The amount of smoothness is determined by the condition that `f(p)=sum((w(i)*(y(i)-s(x(i))))**2) <= s`, with s a given non-negative constant, called the smoothing factor.

The fit `s(x)` is given in the b-spline representation (b-spline coefficients `c[j],j=0,1,...,n-k-2`) and can be evaluated by means of subroutine `splev`.

Fortran calling sequence:
```fortran
   call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,wrk,lwrk,iwrk,ier)
```

Here is a description of the input and output parameters:

| P        | type              | I/O | description |
| ---------|-------------------|-----|-------------|
`iopt`| \*const i32 | I | On entry `iopt` must specify whether a weighted least-squares spline (`iopt=-1`) or a smoothing spline (`iopt= 0` or `1`) must be determined.  If `iopt`=0 the routine will start with an initial set of knots `t(i)`=`xb`, `t(i+k+1)`=`xe`, i=1,2,...  k+1. If `iopt=1` the routine will continue with the knots found at the last call of the routine Attention: a call with `iopt`=1 must always be immediately preceded by another call with `iopt`=1 or `iopt=0`|
`m`| \*const i32 | I | On entry m must specify the number of data points.  `m > k` |
`x`| \*const Vec\<f64\>| I | Array of dimension at least `m`. Before entry, `x[i]` must be set to the i<sup>th</sup> value of the independent variable `x`, for `i=0,1,2,...,m-1`. these values must be supplied in strictly ascending order
`y`| \*const Vec\<f64\>| I | Array of dimension at least `m`. Before entry, `y[i]` must be set to the i<sup>th</sup> value of the dependent variable `y`, for `i=0,1,...,m-1`
`w` | \*const Vec\<f64\>| I | Array of dimension at least `m`. Before entry, `w[i]` must be set to the i<sup>th</sup> value in the set of weights. The `w[i]` must be strictly positive
`xb`,`xe`| \*const f64 | I | On entry `xb` and `xe` must specify the boundaries of the approximation interval. `xb<=x(1)`, `xe>=x(m)`
`k` | \*const i32 | I | On entry `k` must specify the degree of the spline.  `1<=k<=5`. It is recommended to use cubic splines (`k=3`).  The user is strongly dissuaded from choosing `k` even,together with a small `s`-value
`s` | \*const f64 | I | On entry (in case `iopt>=0`) s must specify the smoothing factor. `s>=0`. For advice on the choice of s see further comments
`nest` | \*const i32 | I | On entry nest must contain an over-estimate of the total number of knots of the spline returned, to indicate the storage space available to the routine. `nest >=2*k+2`.  In most practical situation `nest=m/2` will be sufficient.  Always large enough is  `nest=m+k+1`, the number of knots needed for interpolation `s=0`
`n` | \*mut i32 | IO | Unless `ier=10` (in case `iopt >=0`), `n` will contain the total number of knots of the spline approximation returned.  If the computation mode `iopt=1` is used this value of `n` should be left unchanged between subsequent calls.  In case `iopt=-1`, the value of `n` must be specified on entry
`t` | \*mut Vec\<f64\> | IO | Array of dimension at least `nest`.  On successful exit, this array will contain the knots of the spline,i.e. the position of the interior knots `t[k+1],t[k+2] ...,t[n-k-2]` as well as the position of the additional knots `t[0]=t[1]=...=t[k]=xb` and `t[n-k-1]=...=t[n-1]=xe` needed for the b-spline representation.  If the computation mode `iopt=1` is used, the values of `t[0], t[1],...,t[n-1]` should be left unchanged between subsequent calls. If the computation mode `iopt=-1` is used, the values `t[k+1],...,t[n-k-2]` must be supplied by the user, before entry. see also the restrictions (`ier=10`)
`c` | \*mut Vec\<f64\> | O | Array of dimension at least (nest).  On successful exit, this array will contain the coefficients `c[0],c[1],..,c[n-k-2]` in the b-spline representation of `s(x)`
`fp` | \*mut Vec\<f64\> | O | Unless `ier`=10, `fp` contains the weighted sum of squared residuals of the spline approximation returned
`wrk` | \*mut Vec\<f64\> | IO | Array of dimension at least (`m*(k+1)+nest*(7+3*k)`).  Used as working space. If the computation mode `iopt`=1 is used, the values `wrk(1)`,...,`wrk(n)` should be left unchanged between subsequent calls
`lwrk` | \*const i32 | I | On entry,`lwrk` must specify the actual dimension of the array wrk as declared in the calling (sub)program. `lwrk` must not be too small (see `wrk`).|
`iwrk` | \*mut Vec\<i32\> | IO | Array of dimension at least (nest).  Used as working space. If the computation mode `iopt=1` is used,the values `iwrk[0]`,...,`iwrk[n-1]` should be left unchanged between subsequent calls
`ier` | \*mut i32 | IO | Unless the routine detects an error, `ier` contains a non-positive value on exit. For a description see below.

# Error Values

|`ier`| Description |
|:---:|-------------|
-2 | Normal return. The spline returned is the weighted least-squares polynomial of degree `k`. In this extreme case `fp` gives the upper bound `fp0` for the smoothing factor `s`
-1 | Normal return. The spline returned is an interpolating spline (`fp=0`)
0  | Normal return. The spline returned has a residual sum of squares `fp` such that `abs(fp-s)/s <= tol` with `tol` a relative tolerance set to 0.001 by the program.
1  | The required storage space exceeds the available storage space, as specified by the parameter `nest`. Probably causes : `nest` too small.  If `nest` is already large (say `nest > m/2`), it may also indicate that `s` is too small.  The approximation returned is the weighted least-squares spline according to the knots `t(1),t(2),...,t(n)`. (`n=nest`) The parameter `fp` gives the corresponding weighted sum of squared residuals (`fp>s`)
2  | A theoretically impossible result was found during the iteration process for finding a smoothing spline with `fp = s`. Probably causes : `s` too small.  There is an approximation returned but the corresponding weighted sum of squared residuals does not satisfy the condition `abs(fp-s)/s < tol`.
3  | The maximal number of iterations `maxit` (set to 20 by the program) allowed for finding a smoothing spline with `fp=s` has been reached. Probably causes : `s` too small. There is an approximation returned but the corresponding weighted sum of squared residuals does not satisfy the condition `abs(fp-s)/s<tol`
=>10 | Invalid input parameters, see input parameter restrictions

# Input Parameter Restrictions
On entry, the input data are controlled on validity. 
The following restrictions must be satisfied:
- `-1<=iopt<=1`
- `1<=k<=5` 
- `m>k` 
- `nest>2*k+2` 
- `w(i)>0,i=1,2,...,m`
- `xb<=x(1)<x(2)<...<x(m)<=xe`
- `lwrk>=(k+1)*m+nest*(7+3*k)`
- `iopt=-1`
  * `2*k+2<=n<=min(nest,m+k+1)`
  * `xb<t(k+2)<t(k+3)<...<t(n-k-1)<xe`
  * *Schoenberg-Whitney condition:* there must be a subset of data points `xx(j)` such that `t(j) < xx(j) < t(j+k+1), j=1,2,...,n-k-1`
- `iopt>=0`
  *  `s>=0`
  *  if `s=0` : `nest >= m+k+1` 

# Further comments:
-  By means of the parameter `s`, the user can control the tradeoff between closeness of fit and smoothness of fit of the approximation.
If `s` is too large, the spline will be too smooth and signal will be lost; 
If `s` is too small the spline will pick up too much noise. 
In the extreme cases the program will return an interpolating spline if `s=0` and the weighted least-squares polynomial of degree `k` if `s` is very large. 
Between these extremes, a properly chosen `s` will result in a good compromise between closeness of fit and smoothness of fit.
To decide whether an approximation, corresponding to a certain s is satisfactory the user is highly recommended to inspect the fits graphically.
- Recommended values for s depend on the weights `w[i]`. if these are taken as `1/d[i]` with `d[i]` an estimate of the standard deviation of `y[i]`, a good `s`-value should be found in the range `(m-sqrt(2*m),m+sqrt(2*m))`. 
If nothing is known about the statistical error in `y[i]` each `w[i]` can be set equal to one and `s` determined by trial and error, taking account of the comments above. 
The best is then to start with a very large value of `s` (to determine the least-squares polynomial and the corresponding upper bound `fp0` for `s`) and then to progressively decrease the value of `s` (say by a factor 10 in the beginning, i.e. `s=fp0/10, fp0/100,` ...and more carefully as the approximation shows more detail) to obtain closer fits.
- To economize the search for a good `s`-value the program provides with different modes of computation. 
At the first call of the routine, or whenever he wants to restart with the initial set of knots the user must set `iopt=0`.
If `iopt=1` the program will continue with the set of knots found at the last call of the routine. 
This will save a lot of computation time if curfit is called repeatedly for different values of `s`.
- The number of knots of the spline returned and their location will depend on the value of `s` and on the complexity of the shape of the function underlying the data. 
But, if the computation mode `iopt=1` is used, the knots returned may also depend on the `s`-values at previous calls (if these were smaller). 
Therefore, if after a number of trials with different `s`-values and `iopt=1`, the user can finally accept a fit as satisfactory, it may be worthwhile for him to call curfit once more with the selected value for s but now with `iopt=0`.
Indeed, curfit may then return an approximation of the same quality of fit but with fewer knots and therefore better if data reduction is also an important objective for the user.

Other subroutines required: `fpback`,`fpbspl`,`fpchec`,`fpcurf`,`fpdisc`,`fpgivs`,`fpknot`,`fprati`,`fprota`

# References
- Dierckx P., "An algorithm for smoothing, differentiation and integration of experimental data using spline functions", *J.Comp.Appl.Maths 1* (1975) 165-184.
- Dierckx P., "A fast algorithm for smoothing data on a rectangular grid while using spline functions", *SIAM J. Numer. Anal. 19* (1982) 1286-1304.
- Dierckx P., "An improved algorithm for curve fitting with spline functions", *Report TW54, Dept. Computer science, K.U.Leuven*, (1981).
- Dierckx P., "Curve and surface fitting with splines, monographs on numerical analysis", *Oxford University Press*, (1993).

Author: 
  P. Dierckx (Dept. Computer Science, K.U. Leuven)

creation date: may 1979 
latest update: march 1987

