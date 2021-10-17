
#![doc = include_str!("../README.md")]

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

extern {

    pub fn curfit_(
        iopt: &i32,     // iopt -1: Least-squares spline fixed knots, 0,1: smoothing spline. iopt=0 and s=0: interpolating spline
        m: &usize,      // Number of data points supplied
        x: *const f64,  // Array of x coordinates (at least m values)
        y: *const f64,  // Array of y coordinates (at least m values)
        w: *const f64,  // Array weights (at least m values)
        xb: &f64,       // Bounderies of the approximation interval. xb<=x(1), xe<=x(m)
        xe: &f64, 
        k: &usize,      // Degree of the spline, Cubic = 3
        s: &f64,        // Smoothing factor to be used if iopt >= 0
        nest: &usize,   // nest = m + k + 1
        n: &mut usize,  // Number of knots returned. For iopt=-1 value needs to be specified on entry
        t: *mut f64,    // Array of dimension of at least nest. For iopt=-1 array of knots to be used for least-squares spline
        c: *mut f64,    // Double array of at least nest. Will contain the coefficients of the b-spline representation
        fp: &mut f64,   // Weighted sum of the squared residuals of the spline approximation.
        wrk: *mut f64,  // Double array of dimension at least (m(k+1)+nest(7+3k)).
        lwrk: &usize,   // Size of 'wrk'
        iwrk: *mut i32, // int Array of at least nest (m + k + 1)
        ier: &mut i32   // Error flag.
    );

    pub fn splev_(
        t: *const f64,  // array,length n, which contains the position of the knots
        n: &usize,      // integer, giving the total number of knots of s(x). 
        c: *const f64,  // array,length n, which contains the b-spline coefficients
        k: &usize,      // integer, giving the degree of s(x)
        x: *const f64,  // array,length m, which contains the points where s(x) must be evaluated
        y: *mut f64,    // array,length m, giving the value of s(x) at the different points
        m: &usize,      // lenght of x and y
        ier: &mut i32,  // ier = 0 : normal return;  ier =10 : invalid input data : restrictions:  m >= 1, t(k+1) <= x(i) <= x(i+1) <= t(n-k) , i=1,2,...,m-1
    ); 

    pub fn concur_(
        iopt: &i32,     // iopt -1: Least-squares spline fixed knots, 0,1: smoothing spline. iopt=0 and s=0: interpolating spline
        idim: &usize,   // dimension of the curve 0 < idim < 11; e.g. 3: trajectory of a fly flying in your office
        m: &usize,      // Number of data points supplied
        u: *const f64,  // Array of parameter values (e.g. pathlength)
        mx: &usize,     // Array size of data points, idim * m
        x: *const f64,  // Datapoints eg [x0, y0, z0, ... x1, y1.., z1, ..]
        xx: *mut f64,   // mx sized array, used as working space.
        w: *const f64,  // Array weights (at least m values)
        ib: &usize,     // number of derivative constraints for the curve at the begin point: 0<=ib<=(k+1)/2 
                        // choose 0 for only endpoint value (x) , 1 to add first derivative [x, dx/du], 2: to add second [x, dx/du, d2x/du2]
        db: *const f64, // Array with the actural derivative begin point constraints
        nb: &usize,     // Size of db: idim*ib
        ie: &usize,     // number of derivative constraints for the curve at the end point: 0<=ib<=(k+1)/2 
                        // choose 0 for only endpoint value (x) , 1 to add first derivative [x, dx/du], 2: to add second [x, dx/du, d2x/du2]
        de: *const f64, // Array with the actural derivative begin point constraints
        ne: &usize,     // Size of db: idim*ib
        k: &usize,      // Degree of the spline, cubic = 3
        s: &f64,        // Smoothing factor to be used if iopt >= 0
        nest: &usize,   // nest=m+k+1+max(0,ib-1)+max(0,ie-1),
        n: &mut usize,  // Number of knots returned. For iopt=-1 value needs to pe specified on entry
        t: *mut f64,    // Array of dimension of at least nest. For iopt=-1 array of knots to be used for lsq spline
        nc: &usize,     // actual size of array c: nest * idim
        c: *mut f64,    // coefficients of the b-spline representation, with size nc = nest * idim
        np: &usize,     // size of cp: 2 * (k+1) * idim
        cp:*mut f64,    // array at least 2 * (k+1) * idim; spline representation of end points, mainly for internal use
        fp: &mut f64,   // Weighted sum of the squared residuals of the spline approximation.
        wrk: *mut f64,  // Float working array
        lwrk: &usize,   // m*(k+1)+nest*(6+idim+3*k)
        iwrk: *mut i32, // Integer working array
        ier: &mut i32   // Error flag.
    );
}
