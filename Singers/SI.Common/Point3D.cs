using System;
using System.Windows;

namespace SI.Common
{
    /// <summary>
    /// Represents a three dimensional point.
    /// </summary>
    public struct Point3D : IComparable, IEquatable<Point3D>
    {
        #region Properties

        /// <summary>
        /// Get or set the X.
        /// </summary>
        public double X { get; set; }

        /// <summary>
        /// Get or set the Y.
        /// </summary>
        public double Y { get; set; }

        /// <summary>
        /// Get or set the Z.
        /// </summary>
        public double Z { get; set; }

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the Point3D struct.
        /// </summary>
        /// <param name="x">The x position.</param>
        /// <param name="y">The y position.</param>
        /// <param name="z">The z position.</param>
        public Point3D(double x, double y, double z)
        {
            X = x;
            Y = y;
            Z = z;
        }

        #endregion

        #region Methods

        /// <summary>
        /// Get this 3D point as a 2D point.
        /// </summary>
        /// <returns>A 2D point.</returns>
        public Point To2DPoint()
        {
            return new Point(X, Y);
        }

        #endregion

        #region Implementation of IComparable

        /// <summary>
        /// Compares the current instance with another object of the same type and returns an integer that indicates whether the current instance precedes, follows, or occurs in the same position in the sort order as the other object.
        /// </summary>
        /// <returns>
        /// A value that indicates the relative order of the objects being compared. The return value has these meanings: Value Meaning Less than zero This instance precedes <paramref name="obj"/> in the sort order. Zero This instance occurs in the same position in the sort order as <paramref name="obj"/>. Greater than zero This instance follows <paramref name="obj"/> in the sort order. 
        /// </returns>
        /// <param name="obj">An object to compare with this instance. </param><exception cref="T:System.ArgumentException"><paramref name="obj"/> is not the same type as this instance. </exception>
        public int CompareTo(object obj)
        {
            if (!(obj is Point3D)) return -1;
            var point3D = (Point3D)obj;
            const double tollerance = 0.001d;
            if ((Math.Abs(X - point3D.X) < tollerance) &&
                (Math.Abs(Y - point3D.Y) < tollerance) &&
                (Math.Abs(Z - point3D.Z) < tollerance))
            {
                return 0;
            }

            return ((X - point3D.X) + (Y - point3D.Y) + (Z - point3D.Z)) > 0d ? 1 : -1;
        }

        #endregion

        #region Implementation of IEquatable<Point3D>

        /// <summary>
        /// Indicates whether the current object is equal to another object of the same type.
        /// </summary>
        /// <returns>
        /// true if the current object is equal to the <paramref name="other"/> parameter; otherwise, false.
        /// </returns>
        /// <param name="other">An object to compare with this object.</param>
        public bool Equals(Point3D other)
        {
            const double tollerance = 0.001d;
            return ((Math.Abs(X - other.X) < tollerance) &&
                    (Math.Abs(Y - other.Y) < tollerance) &&
                    (Math.Abs(Z - other.Z) < tollerance));
        }

        #endregion
    }
}
