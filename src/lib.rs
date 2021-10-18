
#![doc = include_str!("../README.md")]

use libc::{c_double,c_int, };

/*
  Copyright 2021, Harbers Bik LLC

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

extern "C" {

    pub fn curfit_(
        iopt: *const c_int,     // iopt -1: Least-squares spline fixed knots, 0,1: smoothing spline. iopt=0 and s=0: interpolating spline
        m: *const c_int,        // Number of data points supplied
        x: *const c_double,     // Array of x coordinates (at least m values)
        y: *const c_double,     // Array of y coordinates (at least m values)
        w: *const c_double,     // Array weights (at least m values)
        xb: &c_double,          // Bounderies of the approximation interval. xb<=x(1), xe<=x(m)
        xe: &c_double, 
        k: *const c_int,        // Degree of the spline, Cubic = 3
        s: &c_double,           // Smoothing factor to be used if iopt >= 0
        nest: *const c_int,     // nest = m + k + 1
        n: &mut c_int,          // Number of knots returned. For iopt=-1 value needs to be specified on entry
        t: *mut c_double,       // Array of dimension of at least nest. For iopt=-1 array of knots to be used for least-squares spline
        c: *mut c_double,       // Double array of at least nest. Will contain the coefficients of the b-spline representation
        fp: &mut c_double,      // Weighted sum of the squared residuals of the spline approximation.
        wrk: *mut c_double,     // Double array of dimension at least (m(k+1)+nest(7+3k)).
        lwrk: *const c_int,     // Size of 'wrk'
        iwrk: *mut c_int,       // int Array of at least nest (m + k + 1)
        ier: *mut c_int         // Error flag.
    );

    pub fn splev_(
        t: *const c_double,     // array,length n, which contains the position of the knots
        n: *const c_int,        // integer, giving the total number of knots of s(x). 
        c: *const c_double,     // array,length n, which contains the b-spline coefficients
        k: *const c_int,        // integer, giving the degree of s(x)
        x: *const c_double,     // array,length m, which contains the points where s(x) must be evaluated
        y: *mut c_double,       // array,length m, giving the value of s(x) at the different points
        m: *const c_int,        // lenght of x and y
        ier: *mut c_int,        // ier = 0 : normal return;  ier =10 : invalid input data : restrictions:  m >= 1, t(k+1) <= x(i) <= x(i+1) <= t(n-k) , i=1,2,...,m-1
    ); 

    pub fn concur_(
        iopt: *const c_int,     // iopt -1: Least-squares spline fixed knots, 0,1: smoothing spline. iopt=0 and s=0: interpolating spline
        idim: *const c_int,     // dimension of the curve 0 < idim < 11; e.g. 3: trajectory of a fly flying in your office
        m: *const c_int,        // Number of data points supplied
        u: *const c_double,     // Array of parameter values (e.g. pathlength)
        mx: *const c_int,       // Array size of data points, idim * m
        x: *const c_double,     // Datapoints eg [x0, y0, z0, ... x1, y1.., z1, ..]
        xx: *mut c_double,      // mx sized array, used as working space.
        w: *const c_double,     // Array weights (at least m values)
        ib: *const c_int,       // number of derivative constraints for the curve at the begin point: 0<=ib<=(k+1)/2 
                                // choose 0 for only endpoint value (x) , 1 to add first derivative [x, dx/du], 2: to add second [x, dx/du, d2x/du2]
        db: *const c_double,    // Array with the actural derivative begin point constraints
        nb: *const c_int,       // Size of db: idim*ib
        ie: *const c_int,       // number of derivative constraints for the curve at the end point: 0<=ib<=(k+1)/2 
                                // choose 0 for only endpoint value (x) , 1 to add first derivative [x, dx/du], 2: to add second [x, dx/du, d2x/du2]
        de: *const c_double,    // Array with the actural derivative begin point constraints
        ne: *const c_int,       // Size of db: idim*ib
        k: *const c_int,        // Degree of the spline, cubic = 3
        s: &c_double,           // Smoothing factor to be used if iopt >= 0
        nest: *const c_int,     // nest=m+k+1+max(0,ib-1)+max(0,ie-1),
        n: &mut c_int,          // Number of knots returned. For iopt=-1 value needs to pe specified on entry
        t: *mut c_double,       // Array of dimension of at least nest. For iopt=-1 array of knots to be used for lsq spline
        nc: *const c_int,       // actual size of array c: nest * idim
        c: *mut c_double,       // coefficients of the b-spline representation, with size nc = nest * idim
        np: *const c_int,       // size of cp: 2 * (k+1) * idim
        cp:*mut c_double,       // array at least 2 * (k+1) * idim; spline representation of end points, mainly for internal use
        fp: &mut c_double,      // Weighted sum of the squared residuals of the spline approximation.
        wrk: *mut c_double,     // Float working array
        lwrk: *const c_int,     // m*(k+1)+nest*(6+idim+3*k)
        iwrk: *mut c_int,       // Integer working array
        ier: *mut c_int         // Error flag.
    );
}
