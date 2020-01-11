//
//  SVD.swift
//  fastica
//
//  Created by Christopher Helf on 03.07.15.
//  Copyright (c) 2015 Christopher Helf. All rights reserved.
//

import Foundation
import Accelerate

/**
* Computes the singular value decomposition of A.
*
* Give a matrix A, dimensions M by N, this routine computes its
* singular value decomposition, A = U * W * transpose V. The matrix U
* replaces A on output. The diagonal matrix of singular values, W, is
* output as a vector W. The matrix V (not the transpose of V) is output
* as V. M must be greater or equal to N. If it is smaller then A should
* be filled up to square with zero rows.
*/

// Using function degesvd
public func svd(A : Matrix<Double>) -> (error: Int, U: Matrix<Double>?, W: [Double]?, V: Matrix<Double>?){
    
    var _A  = transpose(A)
    
//    let job : UnsafeMutablePointer<Int8> = UnsafeMutablePointer(("A" as NSString).UTF8String)
    let job : UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.allocate(capacity: 1)
    job.pointee = 0x41

    var _m : __CLPK_integer = __CLPK_integer(_A.rows);
    var _n : __CLPK_integer = __CLPK_integer(_A.columns);
    
    
    var lda : __CLPK_integer = _m;
    var ldu : __CLPK_integer = _m;
    var ldvt : __CLPK_integer = _n;
    
    var wkopt : __CLPK_doublereal = 0
    var lwork : __CLPK_integer = -1;
    var info : __CLPK_integer = 0
    
    
    var s : [Double] = [Double](repeating: 0.0, count: Int(_n))
    var u : [Double] = [Double](repeating: 0.0, count: Int(ldu*_m))
    var vt : [Double] = [Double](repeating: 0.0, count: Int(ldvt*_n))
    
    
    /* Query and allocate the optimal workspace */
    dgesvd_(job, job, &_m, &_n, &_A.grid, &lda, &s, &u, &ldu, &vt, &ldvt, &wkopt, &lwork, &info)
    
    lwork = __CLPK_integer(wkopt);
    var work = [Double](repeating: 0.0, count: Int(lwork))
    
    /* Compute SVD */
    dgesvd_(job, job, &_m, &_n, &_A.grid, &lda, &s, &u, &ldu, &vt, &ldvt, &work, &lwork, &info)
    
    /* Check for convergence */
    if( info > 0 ) {
        print( "The algorithm computing SVD failed to converge." );
        return (-1, nil, nil, nil)
    }
    
    if( info < 0 ) {
        print( "Wrong Parameters provided." );
        return (-1, nil, nil, nil)
    }
    
    /* Get outputs */
    var U: Matrix<Double> = Matrix(grid: u, rows: Int(ldu), columns: Int(_m))
    var VT: Matrix<Double> = Matrix(grid: vt, rows: Int(ldvt), columns: Int(_n))
    var V : Matrix<Double> = transpose(VT)
    U = transpose(U)
    
    return (0, U, s, V)

}

// Using function dgesdd
public func fastsvd(A : Matrix<Double>) -> (error: Int, U: Matrix<Double>?, W: [Double]?, V: Matrix<Double>?){
    
    var _A  = transpose(A)
    
    let job : UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.allocate(capacity: 1)
    job.pointee = 0x41  // 'A'
    
//    let job : UnsafeMutablePointer<Int8> = UnsafeMutablePointer(("A" as NSString).UTF8String)
    
    var _m : __CLPK_integer = __CLPK_integer(_A.columns);
    var _n : __CLPK_integer = __CLPK_integer(_A.rows);
    
    var lda : __CLPK_integer = _m;
    var ldu : __CLPK_integer = _m;
    var ldvt : __CLPK_integer = _n;
    
    var s : [Double] = [Double](repeating: 0.0, count: Int(_n))
    var u : [Double] = [Double](repeating: 0.0, count: Int(ldu*_m))
    var vt : [Double] = [Double](repeating: 0.0, count: Int(ldvt*_n))
    
    var wkopt : __CLPK_doublereal = 0
    var lwork : __CLPK_integer = -1;
    var info : __CLPK_integer = 0
    
    var iwork : [__CLPK_integer] = [__CLPK_integer](repeating: 0, count: Int(8*min(_n,_m)))
    
    dgesdd_(job, &_m, &_n, &_A.grid, &lda, &s, &u, &ldu, &vt, &ldvt, &wkopt, &lwork, &iwork, &info)
    
    lwork = __CLPK_integer(wkopt);
    var work = [Double](repeating: 0.0, count: Int(lwork))
    
    dgesdd_(job, &_m, &_n, &_A.grid, &lda, &s, &u, &ldu, &vt, &ldvt, &work, &lwork, &iwork, &info)
    
    /* Check for convergence */
    if( info > 0 ) {
        print( "The algorithm computing SVD failed to converge." );
        return (-1, nil, nil, nil)
    }
    
    if( info < 0 ) {
        print( "Wrong Parameters provided." );
        return (-1, nil, nil, nil)
    }
    
    /* Get outputs */
    var U: Matrix<Double> = Matrix(grid: u, rows: Int(ldu), columns: Int(_m))
    var VT: Matrix<Double> = Matrix(grid: vt, rows: Int(ldvt), columns: Int(_n))
    var V : Matrix<Double> = transpose(VT)
    U = transpose(U)
    
    job.deallocate()
    
    return (0, U, s, V)
    
}

// The equivalent to the numerical recipes function
public func svdcmp( _ _A : Matrix<Double>) -> (error: Int, U: Matrix<Double>?, W: [Double]?, V: Matrix<Double>?) {
    
    let M = _A.rows
    let N = _A.columns
    
    if( M<N ) {
        
        print("You must augment A with extra zero rows.");
        return (-1, nil, nil, nil)
    }
    
    var W = [Double](repeating: 0.0, count: N)
    var V = Matrix<Double>(rows: N, columns: N, repeatedValue: 0.0)
    var A = _A
    
    var G = 0.0
    var Scale = 0.0
    var ANorm = 0.0
    var rv1 = [Double](repeating: 0.0, count: N)
    
    var NM = 0
    var C = 0.0
    var F = 0.0
    var H = 0.0
    var S = 0.0
    var X = 0.0
    var Y = 0.0
    var Z = 0.0
    var tmp = 0.0
    var flag : Bool = false
    var i = 0
    var its = 0
    var j = 0
    var jj = 0
    var k = 0
    var l = 0
    
//    for i in 0...diagonalMatrixwithVector.count-1 {
    
    for i in 0..<N  {
        l = i + 1;
        rv1[i] = Scale * G;
        G = 0.0;
        S = 0.0;
        Scale = 0.0;
        if( i < M ) {
            for k in i..<M  {
                Scale = Scale + fabs( A[k,i] );
            }
            if( Scale != 0.0 ) {
                for k in i..<M  {
                    A[k,i] = A[k,i] / Scale;
                    S = S + A[k,i] * A[k,i];
                }
                F = A[i,i];
                G = sqrt(S);
                if( F > 0.0 ) {
                    G = -G;
                }
                H = F * G - S;
                A[i,i] = F - G;
                if( i != (N-1) ) {
                    for j in l..<N {
                        S = 0.0;
                        for k in i..<M {
                            S = S + A[k,i] * A[k,j];
                        }
                        F = S / H;
                        for k in i..<M {
                            A[k,j] = A[k,j] + F * A[k,i];
                        }
                    }
                }
                for k in i..<M {
                    A[k,i] = Scale * A[k,i];
                }
            }
        }
        
        W[i] = Scale * G;
        G = 0.0;
        S = 0.0;
        Scale = 0.0;
        if( (i < M) && (i != (N-1)) ) {
            for k in l..<N {
                Scale = Scale + fabs( A[i, k] );
            }
            if( Scale != 0.0 ) {
                for k in l..<N {
                    A[i,k] = A[i,k] / Scale;
                    S = S + A[i,k] * A[i,k];
                }
                F = A[i,l];
                G = sqrt(S);
                if( F > 0.0 ) {
                    G = -G;
                }
                H = F * G - S;
                A[i,l] = F - G;
                for k in 1..<N {
                    rv1[k] = A[i,k] / H;
                }
                if( i != (M-1) ) {
                    for j in l..<M {
                        S = 0.0;
                        for k in 1..<N {
                            S = S + A[j,k] * A[i,k];
                        }
                        for k in 1..<N {
                            A[j,k] = A[j,k] + S * rv1[k];
                        }
                    }
                }
                for k in 1..<N {
                    A[i,k] = Scale * A[i,k];
                }
            }
        }
        tmp = fabs( W[i] ) + fabs( rv1[i] );
        if( tmp > ANorm ) {
            ANorm = tmp;
        }
        
    }
    
    /* Accumulation of right-hand transformations. */
//    for( i   N-1; i >= 0; --i ) {
//    for index in stride(from: 5, to: 1, by: -1) {
    for i in stride (from: N-1, to: 0, by: -1 ) {
        if( i < (N-1) ) {
            if( G != 0.0 ) {
                for j in l..<N {
                    V[j,i] = (A[i,j] / A[i,l]) / G;
                }
                for j in l..<N {
                    S = 0.0;
                    for k in l..<N {
                        S = S + A[i,k] * V[k,j];
                    }
                    for k in l..<N {
                        V[k,j] = V[k,j] + S * V[k,i];
                    }
                }
            }
            for j in l..<N {
                V[i,j] = 0.0;
                V[j,i] = 0.0;
            }
        }
        V[i,i] = 1.0;
        G = rv1[i];
        l = i;
    }
    
    /* Accumulation of left-hand transformations. */
//    for( i = N-1; i >= 0; --i ) {
    for i in stride (from: N-1, to: 0, by: -1 ) {
        l = i + 1;
        G = W[i];
        if( i < (N-1) ) {
            for j in l..<N {
                A[i,j] = 0.0;
            }
        }
        if( G != 0.0 ) {
            G = 1.0 / G;
            if( i != (N-1) ) {
                for j in l..<N {
                    S = 0.0;
                    for k in l..<M {
                        S = S + A[k,i] * A[k,j];
                    }
                    F = (S / A[i,i]) * G;
                    for k in i..<M {
                        A[k,j] = A[k,j] + F * A[k,i];
                    }
                }
            }
            for j in i..<M {
                A[j,i] = A[j,i] * G;
            }
        } else {
            for j in i..<M {
                A[j,i] = 0.0;
            }
        }
        A[i,i] = A[i,i] + 1.0;
    }
    
    /* Diagonalization of the bidiagonal form.
    Loop over singular values. */
//    for( k = (N-1); k >= 0; --k ) {
    for k in stride (from: N-1, to: 0, by: -1 ) {        /* Loop over allowed iterations. */
        for its in 1..<(30+1) {
            /* Test for splitting.
            Note that rv1[0] is always zero. */
            flag = true;
            for l in stride (from: k, to: 0, by: -1 ) {        /* Loop over allowed iterations. */
//            for( l = k; l >= 0; --l ) {
                NM = l - 1;
                if( (fabs(rv1[l]) + ANorm) == ANorm ) {
                    flag = false;
                    break;
                } else if( (fabs(W[NM]) + ANorm) == ANorm ) {
                    break;
                }
            }
            
            /* Cancellation of rv1[l], if l > 0; */
            if( flag ) {
                C = 0.0;
                S = 1.0;
                for i in 1..<(k+1) {
                    F = S * rv1[i];
                    if( (fabs(F) + ANorm) != ANorm ) {
                        G = W[i];
                        H = sqrt( F * F + G * G );
                        W[i] = H;
                        H = 1.0 / H;
                        C = ( G * H );
                        S = -( F * H );
                        for j in 0..<M {
                            Y = A[j,NM];
                            Z = A[j,i];
                            A[j,NM] = (Y * C) + (Z * S);
                            A[j,i] = -(Y * S) + (Z * C);
                        }
                    }
                }
            }
            Z = W[k];
            /* Convergence. */
            if( l == k ) {
                /* Singular value is made nonnegative. */
                if( Z < 0.0 ) {
                    W[k] = -Z;
                    for j in 0..<N {
                        V[j,k] = -V[j,k];
                    }
                }
                break;
            }
            
            if( its >= 30 ) {
                
                print("No convergence in 30 iterations." );
                return (-1, nil, nil, nil)
            }
            

            if( l == N ){
                l = N-1;
            }
            X = W[l];
            NM = k - 1;
            Y = W[NM];
            G = rv1[NM];
            H = rv1[k];
            F = ((Y-Z)*(Y+Z) + (G-H)*(G+H)) / (2.0*H*Y);
            G = sqrt( F * F + 1.0 );
            tmp = G;
            if( F < 0.0 ) {
                tmp = -tmp;
            }
            
            F = ((X-Z)*(X+Z) + H*((Y/(F+tmp))-H)) / X;
            
            /* Next QR transformation. */
            C = 1.0;
            S = 1.0;
            for j in l..<(NM+1) {
                i = j + 1;
                G = rv1[i];
                Y = W[i];
                H = S * G;
                G = C * G;
                Z = sqrt( F * F + H * H );
                rv1[j] = Z;
                C = F / Z;
                S = H / Z;
                F = (X * C) + (G * S);
                G = -(X * S) + (G * C);
                H = Y * S;
                Y = Y * C;
                for jj in 0..<N {
                    X = V[jj,j];
                    Z = V[jj,i];
                    V[jj,j] = (X * C) + (Z * S);
                    V[jj,i] = -(X * S) + (Z * C);
                }
                Z = sqrt( F * F + H * H );
                W[j] = Z;
                
                /* Rotation can be arbitrary if Z = 0. */
                if( Z != 0.0 ) {
                    Z = 1.0 / Z;
                    C = F * Z;
                    S = H * Z;
                }
                F = (C * G) + (S * Y);
                X = -(S * G) + (C * Y);
                for jj in 0..<M {
                    Y = A[jj,j];
                    Z = A[jj,i];
                    A[jj,j] = (Y * C) + (Z * S);
                    A[jj,i] = -(Y * S) + (Z * C);
                }
            }
            rv1[l] = 0.0;
            rv1[k] = F;
            W[k] = X;
        }
    }
    
    return (0, A, W, V)
    
}
