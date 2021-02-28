using System.Linq;
using System.Xml;
using System.Xml.Linq;

namespace SI.Logging
{
    /// <summary>
    /// Represents a helper class for Xml objects.
    /// </summary>
    public static class XmlHelper
    {
        #region StaticMethods

        /// <summary>
        /// Check if a node exists.
        /// </summary>
        /// <param name="doc">The document to search.</param>
        /// <param name="tagName">The tag to search for.</param>
        /// <returns>True if the node exists, else false.</returns>
        public static bool NodeExists(XmlDocument doc, string tagName)
        {
            return doc.Cast<XmlNode>().Any(node => node.Name == tagName);
        }

        /// <summary>
        /// Check if an attribute exists.
        /// </summary>
        /// <param name="node">The node to search.</param>
        /// <param name="attributeName">The attribute to search for.</param>
        /// <returns>True if the attribute exists, else false.</returns>
        public static bool AttributeExists(XmlNode node, string attributeName)
        {
            return node?.Attributes?.Cast<XmlAttribute>().Any(attribute => attribute.Name == attributeName) ?? false;
        }

        /// <summary>
        /// Check if an attribute exists.
        /// </summary>
        /// <param name="doc">The document to search.</param>
        /// <param name="tagName">The tag to search for.</param>
        /// <param name="attributeName">The attribute to search for.</param>
        /// <returns>True if the attribute exists, else false.</returns>
        public static bool AttributeExists(XmlDocument doc, string tagName, string attributeName)
        {
            return doc.GetElementsByTagName(tagName).Cast<XmlNode>().SelectMany(node => node?.Attributes?.Cast<XmlAttribute>()).Any(attribute => attribute.Name == attributeName);
        }

        /// <summary>
        /// Get an attribute.
        /// </summary>
        /// <param name="doc">The document to search.</param>
        /// <param name="tagName">The tag to search for.</param>
        /// <param name="attributeName">The attribute to search for.</param>
        /// <returns>The attribute.</returns>
        public static XmlAttribute GetAttribute(XmlDocument doc, string tagName, string attributeName)
        {
            return doc.GetElementsByTagName(tagName).Cast<XmlNode>().SelectMany(node => node?.Attributes?.Cast<XmlAttribute>()).FirstOrDefault(attribute => attribute.Name == attributeName);
        }

        /// <summary>
        /// Get a inner node from a node, looked up by name.
        /// </summary>
        /// <param name="node">The node to search.</param>
        /// <param name="name">The attribute that is being searched for.</param>
        /// <returns>The node with a name that matches the name argument.</returns>
        public static XmlAttribute GetAttribute(XmlNode node, string name)
        {
            return node?.Attributes?.Cast<XmlAttribute>().FirstOrDefault(attribute => attribute.Name == name);
        }

        /// <summary>
        /// Get a inner node from a node at a specified index.
        /// </summary>
        /// <param name="node">The node to search.</param>
        /// <param name="index">The index of the node.</param>
        /// <returns>The node at the specified index.</returns>
        public static XmlNode GetNode(XmlNode node, short index)
        {
            return index < node?.Attributes?.Count ? node.ChildNodes[index] : null;
        }

        /// <summary>
        /// Get a node.
        /// </summary>
        /// <param name="doc">The document to search.</param>
        /// <param name="tagName">The tag name to search for.</param>
        /// <returns>The node.</returns>
        public static XmlNode GetNode(XmlDocument doc, string tagName)
        {
            return doc.Cast<XmlNode>().FirstOrDefault(node => node.Name == tagName);
        }

        /// <summary>
        /// Get a node.
        /// </summary>
        /// <param name="parentNode">The node to search.</param>
        /// <param name="tagName">The tag name to search for.</param>
        /// <returns>The node.</returns>
        public static XmlNode GetNode(XmlNode parentNode, string tagName)
        {
            return parentNode.ChildNodes.Cast<XmlNode>().FirstOrDefault(node => node.Name == tagName);
        }

        /// <summary>
        /// Convert an X element to a node.
        /// </summary>
        /// <param name="element">The element to convert.</param>
        /// <returns>The converted Xml node.</returns>
        public static XmlNode ConvertXElementToXmlNode(XElement element)
        {
            XmlNode nodeElement;

            using (var xmlReader = element.CreateReader())
            {
                var xmlDoc = new XmlDocument();
                xmlDoc.Load(xmlReader);
                nodeElement = xmlDoc;
            }

            return nodeElement;
        }

        #endregion
    }
}
