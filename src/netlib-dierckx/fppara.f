      subroutine fppara(iopt,idim,m,u,mx,x,w,ub,ue,k,s,nest,tol,maxit,
     * k1,k2,n,t,nc,c,fp,fpint,z,a,b,g,q,nrdata,ier)
c  ..
c  ..scalar arguments..
      real ub,ue,s,tol,fp
      integer iopt,idim,m,mx,k,nest,maxit,k1,k2,n,nc,ier
c  ..array arguments..
      real u(m),x(mx),w(m),t(nest),c(nc),fpint(nest),
     * z(nc),a(nest,k1),b(nest,k2),g(nest,k2),q(m,k1)
      integer nrdata(nest)
c  ..local scalars..
      real acc,con1,con4,con9,cos,fac,fpart,fpms,fpold,fp0,f1,f2,f3,
     * half,one,p,pinv,piv,p1,p2,p3,rn,sin,store,term,ui,wi
      integer i,ich1,ich3,it,iter,i1,i2,i3,j,jj,j1,j2,k3,l,l0,
     * mk1,new,nk1,nmax,nmin,nplus,npl1,nrint,n8
c  ..local arrays..
      real h(7),xi(10)
c  ..function references
      real abs,fprati
      integer max0,min0
c  ..subroutine references..
c    fpback,fpbspl,fpgivs,fpdisc,fpknot,fprota
c  ..
c  set constants
      one = 0.1e+01
      con1 = 0.1e0
      con9 = 0.9e0
      con4 = 0.4e-01
      half = 0.5e0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  part 1: determination of the number of knots and their position     c
c  **************************************************************      c
c  given a set of knots we compute the least-squares curve sinf(u),    c
c  and the corresponding sum of squared residuals fp=f(p=inf).         c
c  if iopt=-1 sinf(u) is the requested curve.                          c
c  if iopt=0 or iopt=1 we check whether we can accept the knots:       c
c    if fp <=s we will continue with the current set of knots.         c
c    if fp > s we will increase the number of knots and compute the    c
c       corresponding least-squares curve until finally fp<=s.         c
c    the initial choice of knots depends on the value of s and iopt.   c
c    if s=0 we have spline interpolation; in that case the number of   c
c    knots equals nmax = m+k+1.                                        c
c    if s > 0 and                                                      c
c      iopt=0 we first compute the least-squares polynomial curve of   c
c      degree k; n = nmin = 2*k+2                                      c
c      iopt=1 we start with the set of knots found at the last         c
c      call of the routine, except for the case that s > fp0; then     c
c      we compute directly the polynomial curve of degree k.           c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  determine nmin, the number of knots for polynomial approximation.
      nmin = 2*k1
      if(iopt.lt.0) go to 60
c  calculation of acc, the absolute tolerance for the root of f(p)=s.
      acc = tol*s
c  determine nmax, the number of knots for spline interpolation.
      nmax = m+k1
      if(s.gt.0.) go to 45
c  if s=0, s(u) is an interpolating curve.
c  test whether the required storage space exceeds the available one.
      n = nmax
      if(nmax.gt.nest) go to 420
c  find the position of the interior knots in case of interpolation.
  10  mk1 = m-k1
      if(mk1.eq.0) go to 60
      k3 = k/2
      i = k2
      j = k3+2
      if(k3*2.eq.k) go to 30
      do 20 l=1,mk1
        t(i) = u(j)
        i = i+1
        j = j+1
  20  continue
      go to 60
  30  do 40 l=1,mk1
        t(i) = (u(j)+u(j-1))*half
        i = i+1
        j = j+1
  40  continue
      go to 60
c  if s>0 our initial choice of knots depends on the value of iopt.
c  if iopt=0 or iopt=1 and s>=fp0, we start computing the least-squares
c  polynomial curve which is a spline curve without interior knots.
c  if iopt=1 and fp0>s we start computing the least squares spline curve
c  according to the set of knots found at the last call of the routine.
  45  if(iopt.eq.0) go to 50
      if(n.eq.nmin) go to 50
      fp0 = fpint(n)
      fpold = fpint(n-1)
      nplus = nrdata(n)
      if(fp0.gt.s) go to 60
  50  n = nmin
      fpold = 0.
      nplus = 0
      nrdata(1) = m-2
c  main loop for the different sets of knots. m is a save upper bound
c  for the number of trials.
  60  do 200 iter = 1,m
        if(n.eq.nmin) ier = -2
c  find nrint, tne number of knot intervals.
        nrint = n-nmin+1
c  find the position of the additional knots which are needed for
c  the b-spline representation of s(u).
        nk1 = n-k1
        i = n
        do 70 j=1,k1
          t(j) = ub
          t(i) = ue
          i = i-1
  70    continue
c  compute the b-spline coefficients of the least-squares spline curve
c  sinf(u). the observation matrix a is built up row by row and
c  reduced to upper triangular form by givens transformations.
c  at the same time fp=f(p=inf) is computed.
        fp = 0.
c  initialize the b-spline coefficients and the observation matrix a.
        do 75 i=1,nc
          z(i) = 0.
  75    continue
        do 80 i=1,nk1
          do 80 j=1,k1
            a(i,j) = 0.
  80    continue
        l = k1
        jj = 0
        do 130 it=1,m
c  fetch the current data point u(it),x(it).
          ui = u(it)
          wi = w(it)
          do 83 j=1,idim
             jj = jj+1
             xi(j) = x(jj)*wi
  83      continue
c  search for knot interval t(l) <= ui < t(l+1).
  85      if(ui.lt.t(l+1) .or. l.eq.nk1) go to 90
          l = l+1
          go to 85
c  evaluate the (k+1) non-zero b-splines at ui and store them in q.
  90      call fpbspl(t,n,k,ui,l,h)
          do 95 i=1,k1
            q(it,i) = h(i)
            h(i) = h(i)*wi
  95      continue
c  rotate the new row of the observation matrix into triangle.
          j = l-k1
          do 110 i=1,k1
            j = j+1
            piv = h(i)
c   GH211017
c           if(piv.eq.0.) go to 110
            if(abs(piv)<epsilon(piv)) go to 110
c  calculate the parameters of the givens transformation.
            call fpgivs(piv,a(j,1),cos,sin)
c  transformations to right hand side.
            j1 = j
            do 97 j2 =1,idim
               call fprota(cos,sin,xi(j2),z(j1))
               j1 = j1+n
  97        continue
            if(i.eq.k1) go to 120
            i2 = 1
            i3 = i+1
            do 100 i1 = i3,k1
              i2 = i2+1
c  transformations to left hand side.
              call fprota(cos,sin,h(i1),a(j,i2))
 100        continue
 110      continue
c  add contribution of this row to the sum of squares of residual
c  right hand sides.
 120      do 125 j2=1,idim
             fp  = fp+xi(j2)**2
 125      continue
 130    continue
        if(ier.eq.(-2)) fp0 = fp
        fpint(n) = fp0
        fpint(n-1) = fpold
        nrdata(n) = nplus
c  backward substitution to obtain the b-spline coefficients.
        j1 = 1
        do 135 j2=1,idim
           call fpback(a,z(j1),nk1,k1,c(j1),nest)
           j1 = j1+n
 135    continue
c  test whether the approximation sinf(u) is an acceptable solution.
        if(iopt.lt.0) go to 440
        fpms = fp-s
        if(abs(fpms).lt.acc) go to 440
c  if f(p=inf) < s accept the choice of knots.
        if(fpms.lt.0.) go to 250
c  if n = nmax, sinf(u) is an interpolating spline curve.
        if(n.eq.nmax) go to 430
c  increase the number of knots.
c  if n=nest we cannot increase the number of knots because of
c  the storage capacity limitation.
        if(n.eq.nest) go to 420
c  determine the number of knots nplus we are going to add.
        if(ier.eq.0) go to 140
        nplus = 1
        ier = 0
        go to 150
 140    npl1 = nplus*2
        rn = nplus
c   GH211017 Added explicit int conversion
        if(fpold-fp.gt.acc) npl1 = int(rn*fpms/(fpold-fp))
        nplus = min0(nplus*2,max0(npl1,nplus/2,1))
 150    fpold = fp
c  compute the sum of squared residuals for each knot interval
c  t(j+k) <= u(i) <= t(j+k+1) and store it in fpint(j),j=1,2,...nrint.
        fpart = 0.
        i = 1
        l = k2
        new = 0
        jj = 0
        do 180 it=1,m
          if(u(it).lt.t(l) .or. l.gt.nk1) go to 160
          new = 1
          l = l+1
 160      term = 0.
          l0 = l-k2
          do 175 j2=1,idim
            fac = 0.
            j1 = l0
            do 170 j=1,k1
              j1 = j1+1
              fac = fac+c(j1)*q(it,j)
 170        continue
            jj = jj+1
            term = term+(w(it)*(fac-x(jj)))**2
            l0 = l0+n
 175      continue
          fpart = fpart+term
          if(new.eq.0) go to 180
          store = term*half
          fpint(i) = fpart-store
          i = i+1
          fpart = store
          new = 0
 180    continue
        fpint(nrint) = fpart
        do 190 l=1,nplus
c  add a new knot.
          call fpknot(u,m,t,n,fpint,nrdata,nrint,nest,1)
c  if n=nmax we locate the knots as for interpolation
          if(n.eq.nmax) go to 10
c  test whether we cannot further increase the number of knots.
          if(n.eq.nest) go to 200
 190    continue
c  restart the computations with the new set of knots.
 200  continue
c  test whether the least-squares kth degree polynomial curve is a
c  solution of our approximation problem.
 250  if(ier.eq.(-2)) go to 440
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  part 2: determination of the smoothing spline curve sp(u).          c
c  **********************************************************          c
c  we have determined the number of knots and their position.          c
c  we now compute the b-spline coefficients of the smoothing curve     c
c  sp(u). the observation matrix a is extended by the rows of matrix   c
c  b expressing that the kth derivative discontinuities of sp(u) at    c
c  the interior knots t(k+2),...t(n-k-1) must be zero. the corres-     c
c  ponding weights of these additional rows are set to 1/p.            c
c  iteratively we then have to determine the value of p such that f(p),c
c  the sum of squared residuals be = s. we already know that the least c
c  squares kth degree polynomial curve corresponds to p=0, and that    c
c  the least-squares spline curve corresponds to p=infinity. the       c
c  iteration process which is proposed here, makes use of rational     c
c  interpolation. since f(p) is a convex and strictly decreasing       c
c  function of p, it can be approximated by a rational function        c
c  r(p) = (u*p+v)/(p+w). three values of p(p1,p2,p3) with correspond-  c
c  ing values of f(p) (f1=f(p1)-s,f2=f(p2)-s,f3=f(p3)-s) are used      c
c  to calculate the new value of p such that r(p)=s. convergence is    c
c  guaranteed by taking f1>0 and f3<0.                                 c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  evaluate the discontinuity jump of the kth derivative of the
c  b-splines at the knots t(l),l=k+2,...n-k-1 and store in b.
      call fpdisc(t,n,k2,b,nest)
c  initial value for p.
      p1 = 0.
      f1 = fp0-s
      p3 = -one
      f3 = fpms
      p = 0.
      do 252 i=1,nk1
         p = p+a(i,1)
 252  continue
      rn = nk1
      p = rn/p
      ich1 = 0
      ich3 = 0
      n8 = n-nmin
c  iteration process to find the root of f(p) = s.
      do 360 iter=1,maxit
c  the rows of matrix b with weight 1/p are rotated into the
c  triangularised observation matrix a which is stored in g.
        pinv = one/p
        do 255 i=1,nc
          c(i) = z(i)
 255    continue
        do 260 i=1,nk1
          g(i,k2) = 0.
          do 260 j=1,k1
            g(i,j) = a(i,j)
 260    continue
        do 300 it=1,n8
c  the row of matrix b is rotated into triangle by givens transformation
          do 270 i=1,k2
            h(i) = b(it,i)*pinv
 270      continue
          do 275 j=1,idim
            xi(j) = 0.
 275      continue
          do 290 j=it,nk1
            piv = h(1)
c  calculate the parameters of the givens transformation.
            call fpgivs(piv,g(j,1),cos,sin)
c  transformations to right hand side.
            j1 = j
            do 277 j2=1,idim
              call fprota(cos,sin,xi(j2),c(j1))
              j1 = j1+n
 277        continue
            if(j.eq.nk1) go to 300
            i2 = k1
            if(j.gt.n8) i2 = nk1-j
            do 280 i=1,i2
c  transformations to left hand side.
              i1 = i+1
              call fprota(cos,sin,h(i1),g(j,i1))
              h(i) = h(i1)
 280        continue
            h(i2+1) = 0.
 290      continue
 300    continue
c  backward substitution to obtain the b-spline coefficients.
        j1 = 1
        do 305 j2=1,idim
          call fpback(g,c(j1),nk1,k2,c(j1),nest)
          j1 =j1+n
 305    continue
c  computation of f(p).
        fp = 0.
        l = k2
        jj = 0
        do 330 it=1,m
          if(u(it).lt.t(l) .or. l.gt.nk1) go to 310
          l = l+1
 310      l0 = l-k2
          term = 0.
          do 325 j2=1,idim
            fac = 0.
            j1 = l0
            do 320 j=1,k1
              j1 = j1+1
              fac = fac+c(j1)*q(it,j)
 320        continue
            jj = jj+1
            term = term+(fac-x(jj))**2
            l0 = l0+n
 325      continue
          fp = fp+term*w(it)**2
 330    continue
c  test whether the approximation sp(u) is an acceptable solution.
        fpms = fp-s
        if(abs(fpms).lt.acc) go to 440
c  test whether the maximal number of iterations is reached.
        if(iter.eq.maxit) go to 400
c  carry out one more step of the iteration process.
        p2 = p
        f2 = fpms
        if(ich3.ne.0) go to 340
        if((f2-f3).gt.acc) go to 335
c  our initial choice of p is too large.
        p3 = p2
        f3 = f2
        p = p*con4
        if(p.le.p1) p=p1*con9 + p2*con1
        go to 360
 335    if(f2.lt.0.) ich3=1
 340    if(ich1.ne.0) go to 350
        if((f1-f2).gt.acc) go to 345
c  our initial choice of p is too small
        p1 = p2
        f1 = f2
        p = p/con4
        if(p3.lt.0.) go to 360
        if(p.ge.p3) p = p2*con1 + p3*con9
        go to 360
 345    if(f2.gt.0.) ich1=1
c  test whether the iteration process proceeds as theoretically
c  expected.
 350    if(f2.ge.f1 .or. f2.le.f3) go to 410
c  find the new value for p.
        p = fprati(p1,f1,p2,f2,p3,f3)
 360  continue
c  error codes and messages.
 400  ier = 3
      go to 440
 410  ier = 2
      go to 440
 420  ier = 1
      go to 440
 430  ier = -1
 440  return
      end
