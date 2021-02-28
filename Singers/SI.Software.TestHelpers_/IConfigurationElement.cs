
using System;
using C5;

namespace SI.Software.TestHelpers
{
    public interface INamedElement
    {
        string Name { get; }
    }

    public interface IElement : INamedElement
    {
        IElement Parent { get; }
        IElement[] GetChildren();
        IElementCollection GetChildCollection();
        object GetAttributeRecursive(string name);
        //T? GetAttributeRecursive2<T>(string name) where T : struct;
    }

    public interface IDatabaseElement : IElement
    {
        string Database { get; }
        bool? CheckDbState { get; }
        void GetDatabases(TreeSet<string> set);
    }

    public interface IElementCollection
    {
        IElement[] GetChildren();
    }

    //public interface IElementAndDatabaseElement : IElement, IDatabaseElement
    //{
    //}

    public interface ISection : IElement
    {
    }
}
