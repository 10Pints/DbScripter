namespace SI.Software.Tools.CustomConfiguration
{
    // ReSharper disable once IdentifierTypo
    public interface IIndexable<out T> : IIndexable
    {
        new T this[int index] { get; }
        new T this[string key] { get; }
    }
}