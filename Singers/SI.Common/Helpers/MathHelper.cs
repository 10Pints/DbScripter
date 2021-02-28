using System;
using System.Windows;

namespace SI.Common.Helpers
{
    /// <summary>
    /// Represents a class for providing mathematic helper functions.
    /// </summary>
    public static class MathHelper
    {
        #region Constants

        /// <summary>
        /// Get a value representing infinite.
        /// </summary>
        public const int Infinite = -1;

        #endregion

        #region StaticMethods

        /// <summary>
        /// Get if a point is within a rectangle.
        /// </summary>
        /// <param name="point">The point to test.</param>
        /// <param name="rectangle">The rectangle.</param>
        /// <returns>True if the point is within the rectangle.</returns>
        public static bool IsPointInRectangle(Point point, Rect rectangle)
        {
            return ((point.X >= rectangle.X) &&
                    (point.X <= rectangle.X + rectangle.Width) &&
                    (point.Y >= rectangle.Y) &&
                    (point.Y <= rectangle.Y + rectangle.Height));
        }

        /// <summary>
        /// Get if a point is within an ellipse.
        /// </summary>
        /// <param name="point">The point to test.</param>
        /// <param name="center">The center of the ellipse.</param>
        /// <param name="radiusX">The radius X of the ellipse.</param>
        /// <param name="radiusY">The radius Y of the ellipse.</param>
        /// <returns>True if the point is within the ellipse.</returns>
        public static bool IsPointInEllipse(Point point, Point center, double radiusX, double radiusY)
        {
            // based on https://stackoverflow.com/questions/13285007/how-to-determine-if-a-point-is-within-an-ellipse

            if ((radiusX <= 0.0) || (radiusY <= 0.0))
                return false;

            var normalizedPoint = new Point(point.X - center.X, point.Y - center.Y);

            return ((normalizedPoint.X * normalizedPoint.X) / (radiusX * radiusX)) + ((normalizedPoint.Y * normalizedPoint.Y) / (radiusY * radiusY)) <= 1.0;
        }

        /// <summary>
        /// Get if a point is in a triangle.
        /// </summary>
        /// <param name="point">The point to test.</param>
        /// <param name="trianglePoint1">The first point.</param>
        /// <param name="trianglePoint2">The second point.</param>
        /// <param name="trianglePoint3">The third point.</param>
        /// <returns>True if the point is in the triangle, else false.</returns>
        public static bool IsPointInTriangle(Point point, Point trianglePoint1, Point trianglePoint2, Point trianglePoint3)
        {
            var b1 = GetSign(point, trianglePoint1, trianglePoint2) < 0.0f;
            var b2 = GetSign(point, trianglePoint2, trianglePoint3) < 0.0f;
            var b3 = GetSign(point, trianglePoint3, trianglePoint1) < 0.0f;

            return ((b1 == b2) && (b2 == b3));
        }

        /// <summary>
        /// Get if a point is in a triangle using barycentric co-ordinates.
        /// </summary>
        /// <param name="point">The point to test.</param>
        /// <param name="trianglePoint1">The first point.</param>
        /// <param name="trianglePoint2">The second point.</param>
        /// <param name="trianglePoint3">The third point.</param>
        /// <returns>True if the point is in the triangle, else false.</returns>
        public static bool IsPointInTriangleBarycentric(Point point, Point trianglePoint1, Point trianglePoint2, Point trianglePoint3)
        {
            // use barycentric coordinates, based on http://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle

            var s = trianglePoint1.Y * trianglePoint3.X - trianglePoint1.X * trianglePoint3.Y + (trianglePoint3.Y - trianglePoint1.Y) * point.X + (trianglePoint1.X - trianglePoint3.X) * point.Y;
            var t = trianglePoint1.X * trianglePoint2.Y - trianglePoint1.Y * trianglePoint2.X + (trianglePoint1.Y - trianglePoint2.Y) * point.X + (trianglePoint2.X - trianglePoint1.X) * point.Y;

            if ((s < 0) != (t < 0))
                return false;

            var area = -trianglePoint2.Y * trianglePoint3.X + trianglePoint1.Y * (trianglePoint3.X - trianglePoint2.X) + trianglePoint1.X * (trianglePoint2.Y - trianglePoint3.Y) + trianglePoint2.X * trianglePoint3.Y;

            if (area < 0)
            {
                s = -s;
                t = -t;
                area = -area;
            }

            return ((s > 0) && (t > 0) && ((s + t) <= area));
        }

        /// <summary>
        /// Method to compute the centroid of a triangle.
        /// </summary>
        /// <param name="trianglePoint1">The first point.</param>
        /// <param name="trianglePoint2">The second point.</param>
        /// <param name="trianglePoint3">The third point.</param>
        /// <returns>The centroid point.</returns>
        public static Point GetCentroid(Point trianglePoint1, Point trianglePoint2, Point trianglePoint3)
        {
            // based on https://stackoverflow.com/questions/9815699/how-to-calculate-centroid and https://www.mathsisfun.com/geometry/triangle-centers.html
            var accumulatedArea = 0d;
            var centerX = 0d;
            var centerY = 0d;
            var points = new[] { trianglePoint1, trianglePoint2, trianglePoint3 };

            for (int i = 0, j = 2; i < 2; j = i++)
            {
                var temp = points[i].X * points[j].Y - points[j].X * points[i].Y;
                accumulatedArea += temp;
                centerX += (points[i].X + points[j].X) * temp;
                centerY += (points[i].Y + points[j].Y) * temp;
            }

            // avoid division by zero
            if (Math.Abs(accumulatedArea) < 1E-7f)
                return new Point();

            accumulatedArea *= 3f;
            return new Point(centerX / accumulatedArea, centerY / accumulatedArea);
        }

        /// <summary>
        /// Determine the distance between a point and a line.
        /// </summary>
        /// <param name="point">The point.</param>
        /// <param name="lineA">The first point in the line.</param>
        /// <param name="lineB">The second point in the line.</param>
        /// <returns>The distance between the point and the line.</returns>
        public static double DistanceFromPointToLine(Point point, Point lineA, Point lineB)
        {
            // based on http://www.java2s.com/Code/CSharp/Development-Class/DistanceFromPointToLine.htm
            // given a line based on two points, and a point away from the line, find the perpendicular distance from the point to the line.
            // see http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html for explanation and definition.

            return Math.Abs((lineB.X - lineA.X) * (lineA.Y - point.Y) - (lineA.X - point.X) * (lineB.Y - lineA.Y)) / Math.Sqrt(Math.Pow(lineB.X - lineA.X, 2) + Math.Pow(lineB.Y - lineA.Y, 2));
        }

        /// <summary>
        /// Determine if two lines intersect.
        /// </summary>
        /// <param name="lineAStart">The start point of line A.</param>
        /// <param name="lineAEnd">The end point of line A.</param>
        /// <param name="lineBStart">The start point of line B.</param>
        /// <param name="lineBEnd">The end point of line B.</param>
        /// <param name="intersection">The point at which the lines intersect.</param>
        /// <returns>True if the lines intersect, else false.</returns>
        public static bool DoLinesIntersect(Point lineAStart, Point lineAEnd, Point lineBStart, Point lineBEnd, out Point intersection)
        {
            // based on https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect

            var s1_x = lineAEnd.X - lineAStart.X;
            var s1_y = lineAEnd.Y - lineAStart.Y;
            var s2_x = lineBEnd.X - lineBStart.X;
            var s2_y = lineBEnd.Y - lineBStart.Y;

            var s = (-s1_y * (lineAStart.X - lineBStart.X) + s1_x * (lineAStart.Y - lineBStart.Y)) / (-s2_x * s1_y + s1_x * s2_y);
            var t = (s2_x * (lineAStart.Y - lineBStart.Y) - s2_y * (lineAStart.X - lineBStart.X)) / (-s2_x * s1_y + s1_x * s2_y);

            if ((s >= 0) &&
                (s <= 1) &&
                (t >= 0) &&
                (t <= 1))
            {
                intersection = new Point(lineAStart.X + (t * s1_x), lineAStart.Y + (t * s1_y));
                return true;
            }

            intersection = new Point(0, 0);
            return false;
        }

        /// <summary>
        /// Determine the distance between two points in 3D space.
        /// </summary>
        /// <param name="a">Point a.</param>
        /// <param name="b">Point b.</param>
        /// <returns>The distance in 3D space.</returns>
        public static double DistanceBetweenTwo3DPoints(Point3D a, Point3D b)
        {
            return Math.Abs(Math.Sqrt(((a.X - b.X) * (a.X - b.X)) + ((a.Y - b.Y) * (a.Y - b.Y)) + ((a.Z - b.Z) * (a.Z - b.Z))));
        }

        /// <summary>
        /// Determine the distance between two points.
        /// </summary>
        /// <param name="a">The first point.</param>
        /// <param name="b">The second point.</param>
        /// <returns>The distance between the two points.</returns>
        public static double DistanceBetweenTwoPoints(Point a, Point b)
        {
            return Math.Abs(Math.Sqrt(((b.X - a.X) * (b.X - a.X)) + ((b.Y - a.Y) * (b.Y - a.Y))));
        }

        /// <summary>
        /// Determine the distance between two points.
        /// </summary>
        /// <param name="aX">Point a x location.</param>
        /// <param name="aY">Point a y location.</param>
        /// <param name="bX">Point b x location.</param>
        /// <param name="bY">Point b y location.</param>
        /// <returns>The distance between the two points.</returns>
        public static double DistanceBetweenTwoPoints(double aX, double aY, double bX, double bY)
        {
            return Math.Abs(Math.Sqrt(((bX - aX) * (bX - aX)) + ((bY - aY) * (bY - aY))));
        }

        /// <summary>
        /// Determine if two regular circles intersect each other.
        /// </summary>
        /// <param name="aLeft">The a left position.</param>
        /// <param name="aTop">The a top position.</param>
        /// <param name="aWidth">The a width.</param>
        /// <param name="aHeight">The a height.</param>
        /// <param name="bLeft">The b left position.</param>
        /// <param name="bTop">The b top position.</param>
        /// <param name="bWidth">The be width.</param>
        /// <param name="bHeight">The b height.</param>
        /// <returns>True if the ellipses intersect or touch, else false.</returns>
        public static bool DoRegularCirclesIntersect(double aLeft, double aTop, double aWidth, double aHeight, double bLeft, double bTop, double bWidth, double bHeight)
        {
            if ((Math.Abs(aWidth - aHeight) > 0.0) || (Math.Abs(bWidth - bHeight) > 0.0))
                return new Rect(aLeft, aTop, aWidth, aHeight).IntersectsWith(new Rect(bLeft, bTop, bWidth, bHeight));

            return DistanceBetweenTwoPoints(aLeft + (aWidth / 2d), aTop + (aHeight / 2d), bLeft + (bWidth / 2d), bTop + (bHeight / 2d)) <= ((aWidth / 2d) + (bWidth / 2d));
        }

        /// <summary>
        /// Determine if two regular circles intersect each other on a path.
        /// </summary>
        /// <param name="endALeft">The a left position.</param>
        /// <param name="endATop">The a top position.</param>
        /// <param name="startALeft">The start left position of the a ellipse.</param>
        /// <param name="startATop">The start top position of the a ellipse.</param>
        /// <param name="aWidth">The a width.</param>
        /// <param name="aHeight">The a height.</param>
        /// <param name="endBLeft">The b left position.</param>
        /// <param name="endBTop">The b top position.</param>
        /// <param name="bWidth">The be width.</param>
        /// <param name="bHeight">The b height.</param>
        /// <param name="startBLeft">The start left position of the a ellipse.</param>
        /// <param name="startBTop">The start top position of the a ellipse.</param>
        /// <param name="steps">The amount of steps to check on the vector path.</param>
        /// <returns>True if the ellipses intersect or touch, else false.</returns>
        public static bool DoRegularCirclesIntersectOnVectorPath(double endALeft, double endATop, double startALeft, double startATop, double aWidth, double aHeight, double endBLeft, double endBTop, double startBLeft, double startBTop, double bWidth, double bHeight, int steps)
        {
            var appliedSteps = Math.Min(((Math.Abs(endALeft - startALeft) > 0.0) || (Math.Abs(endATop - startATop) > 0.0) || (Math.Abs(endBLeft - startBLeft) > 0.0) || (Math.Abs(endBTop - startBTop) > 0.0)) ? steps : 1, 10);

            for (var index = 0; index < appliedSteps; index++)
                if (DoRegularCirclesIntersect(endALeft - (((startALeft - endALeft) / appliedSteps) * (appliedSteps - index)), endATop - (((startATop - endATop) / appliedSteps) * (appliedSteps - index)), aWidth, aHeight, endBLeft - (((startBLeft - endBLeft) / appliedSteps) * (appliedSteps - index)), endBTop - (((startBTop - endBTop) / appliedSteps) * (appliedSteps - index)), bWidth, bHeight))
                    return true;

            return false;
        }

        /// <summary>
        /// Determine if two regular circles fully overlap each other.
        /// </summary>
        /// <param name="aLeft">The a left position.</param>
        /// <param name="aTop">The a top position.</param>
        /// <param name="aRadius">The a radius.</param>
        /// <param name="bLeft">The b left position.</param>
        /// <param name="bTop">The b top position.</param>
        /// <param name="bRadius">The b radius.</param>
        /// <returns>True if the ellipses fully overlap, else false.</returns>
        public static bool DoRegularCirclesOverlap(double aLeft, double aTop, double aRadius, double bLeft, double bTop, double bRadius)
        {
            return DistanceBetweenTwoPoints(aLeft + aRadius, aTop + aRadius, bLeft + bRadius, bTop + bRadius) <= Math.Max(aRadius, bRadius) - Math.Min(aRadius, bRadius);
        }

        /// <summary>
        /// Determine if regular circle A is fully enclosed within regular circle B.
        /// </summary>
        /// <param name="a">The center of A.</param>
        /// <param name="aRadius">The radius.</param>
        /// <param name="b">The center of B.</param>
        /// <param name="bRadius">The radius of B.</param>
        /// <returns>True if A is fully enclosed within B, else false.</returns>
        public static bool IsRegularCircleAEnclosedWithinRegularCircleB(Point a, double aRadius, Point b, double bRadius)
        {
            return IsRegularCircleAEnclosedWithinRegularCircleB(a.X, a.Y, aRadius, b.X, b.Y, bRadius);
        }

        /// <summary>
        /// Determine if regular circle A is fully enclosed within regular circle B.
        /// </summary>
        /// <param name="aX">The center of A X.</param>
        /// <param name="aY">The center of A X.</param>
        /// <param name="aRadius">The radius.</param>
        /// <param name="bX">The center of B X.</param>
        /// <param name="bY">The center of B Y.</param>
        /// <param name="bRadius">The radius of B.</param>
        /// <returns>True if A is fully enclosed within B, else false.</returns>
        public static bool IsRegularCircleAEnclosedWithinRegularCircleB(double aX, double aY, double aRadius, double bX, double bY, double bRadius)
        {
            var distanceBetweenCenters = DistanceBetweenTwoPoints(aX, aY, bX, bY);
            return distanceBetweenCenters + aRadius <= bRadius;
        }

        /// <summary>
        /// Determine if regular circle A is fully enclosed within regular circle B.
        /// </summary>
        /// <param name="aX">The center of A X.</param>
        /// <param name="aY">The center of A X.</param>
        /// <param name="aRadius">The radius.</param>
        /// <param name="bX">The center of B X.</param>
        /// <param name="bY">The center of B Y.</param>
        /// <param name="bRadius">The radius of B.</param>
        /// <param name="percentage">The percentage circle A is enclosed by circle B</param>
        /// <returns>True if A is fully enclosed within B, else false.</returns>
        public static bool IsRegularCircleAEnclosedWithinRegularCircleBByPercentage(double aX, double aY, double aRadius, double bX, double bY, double bRadius, int percentage)
        {
            var distanceBetweenCenters = DistanceBetweenTwoPoints(aX, aY, bX, bY);
            return distanceBetweenCenters + aRadius * (percentage / 100) <= bRadius;
        }

        /// <summary>
        /// Determine if regular circle A is semi-enclosed within regular circle B.
        /// </summary>
        /// <param name="a">The center of A.</param>
        /// <param name="aRadius">The radius.</param>
        /// <param name="b">The center of B.</param>
        /// <param name="bRadius">The radius of B.</param>
        /// <param name="normalisedIntersectionThreshold">A value between 0-1 that acts as a ratio of circle A that must be within circle B for circle A to be considered semi-enclosed.</param>
        /// <returns>True if A is semi-enclosed within B, else false.</returns>
        public static bool IsRegularCircleASemiEnclosedWithinRegularCircleB(Point a, double aRadius, Point b, double bRadius, double normalisedIntersectionThreshold)
        {
            return IsRegularCircleASemiEnclosedWithinRegularCircleB(a.X, a.Y, aRadius, b.X, b.Y, bRadius, normalisedIntersectionThreshold);
        }

        /// <summary>
        /// Determine if regular circle A is semi-enclosed within regular circle B.
        /// </summary>
        /// <param name="aX">The center of A X.</param>
        /// <param name="aY">The center of A X.</param>
        /// <param name="aRadius">The radius.</param>
        /// <param name="bX">The center of B X.</param>
        /// <param name="bY">The center of B Y.</param>
        /// <param name="bRadius">The radius of B.</param>
        /// <param name="normalisedIntersectionThreshold">A value between 0-1 that acts as a ratio of circle A that must be within circle B for circle A to be considered semi-enclosed.</param>
        /// <returns>True if A is semi-enclosed within B, else false.</returns>
        public static bool IsRegularCircleASemiEnclosedWithinRegularCircleB(double aX, double aY, double aRadius, double bX, double bY, double bRadius, double normalisedIntersectionThreshold)
        {
            var proportion = -aRadius + (normalisedIntersectionThreshold * (2d * aRadius));
            var distanceBetweenTwoPoints = DistanceBetweenTwoPoints(aX, aY, bX, bY);
            return Math.Abs(distanceBetweenTwoPoints + proportion) <= bRadius;
        }

        /// <summary>
        /// Determine a projected collision point for an Ellipse once a vector has been applied to it.
        /// </summary>
        /// <param name="ellipse">The rectangle that bounds a virtual Ellipse to use for determining the collision point.</param>
        /// <param name="vector">The vector of the ellipse.</param>
        /// <returns>The 2D point describing where to use for testing a projected collision.</returns>
        public static Point DetermineProjectedCollisionPoint(Rect ellipse, Vector vector)
        {
            // -calculate center point of ellipse
            // -using vector to get angle find the point on the ellipse that is going to connect first
            // -add VectorX and VectorY to projected point

            var angle = Math.Atan(vector.X / vector.Y);
            var collisionPoint = new Point(ellipse.Left + (ellipse.Width / 2d), ellipse.Top + (ellipse.Height / 2d));
            collisionPoint.X += Math.Sin(angle) * (ellipse.Width / 2d);
            collisionPoint.Y += Math.Cos(angle) * (ellipse.Height / 2d);
            collisionPoint.X += vector.X;
            collisionPoint.Y += vector.Y;
            return collisionPoint;
        }

        /// <summary>
        /// Calculate the hypotenuse side of a right angled triangle.
        /// </summary>
        /// <param name="sideA">The length of side a.</param>
        /// <param name="sideB">The length of side b.</param>
        /// <returns>The length of side c.</returns>
        public static double GetHypotenuse(double sideA, double sideB)
        {
            return Math.Sqrt((sideA * sideA) + (sideB * sideB));
        }

        /// <summary>
        /// Convert degrees to radians.
        /// </summary>
        /// <param name="degrees">The value to convert, in degrees.</param>
        /// <returns>The converted value, in radians.</returns>
        public static double ConvertDegreesToRadians(double degrees)
        {
            return (Math.PI / 180) * degrees;
        }

        /// <summary>
        /// Convert radians to degrees.
        /// </summary>
        /// <param name="radians">The value to convert, in radians.</param>
        /// <returns>The converted value, in degrees.</returns>
        public static double ConvertRadiansToDegrees(double radians)
        {
            return (180 / Math.PI) * radians;
        }

        /// <summary>
        /// Get the sign of 3 points.
        /// </summary>
        /// <param name="a">Point A.</param>
        /// <param name="b">Point B.</param>
        /// <param name="c">Point C.</param>
        /// <returns>The sign.</returns>
        private static double GetSign(Point a, Point b, Point c)
        {
            return (a.X - c.X) * (b.Y - c.Y) - (b.X - c.X) * (a.Y - c.Y);
        }

        #endregion
    }
}
