
#nullable enable

using System;
using System.Text.RegularExpressions;
using System.Collections.Generic;

namespace RSS.Test//UnitTests
{
   public class Counts 
   {
      protected int Count                { get=> Hits.Count; /*private set;*/}

      public List<string> Hits { get; private set; } = new ();
      public MatchCollection? Matches    { get; private set; } = null;
      
      protected string? SearchClause      { get; private set; }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="script"></param>
      /// <param name="clause">regex search clause</param>
      public Counts(string? script = null, string? searchClause = null)
      {
         if((!string.IsNullOrEmpty(script)) && (!string.IsNullOrEmpty(searchClause)))
            Search(script, searchClause);
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="script"></param>
      /// <param name="clause">regex search clause</param>
      private void Search(string? script, string? searchClause)
      {
         Hits.Clear();
         Matches      = null;
         SearchClause = searchClause; 

         if(string.IsNullOrEmpty(script) || string.IsNullOrEmpty(searchClause))
            return; 

         string line;
         //var  pattern = $@"^{Verb} VIEW[ \t]*(.*)";
         var    pattern = $@"{SearchClause}";
         Matches= Regex.Matches(script, pattern, RegexOptions.Multiline | RegexOptions.IgnoreCase);
         var numFnsAct = Matches.Count;

         foreach (System.Text.RegularExpressions.Match m in Matches)
         { 
            line = $"{m.Value}";

            if(!line.EndsWith("\n"))
               line += "\n";

            Hits.Add(line.Trim());
         }
      }
   }
}
/*
      private void LoadTables(string script)
      {
         string line;
         ExportedTables.Clear();
         var    pattern = $@"^{Verb} TABLE\s(.*)";
         MatchCollection matches= Regex.Matches(script, pattern, RegexOptions.Multiline | RegexOptions.IgnoreCase);
         var numFnsAct = matches.Count;

         foreach (System.Text.RegularExpressions.Match m in matches)
         { 
            //string line = $"{m.Groups[2].Value}\t\t {m.Groups[1].Value}\t\t{m.Groups[0].Value}";
            line = $"{m.Name}";

            // add game to list if not contained
            Console.WriteLine(line);
            var key = line;
            var val = line;
            ExportedTables.Add(key, val);
         }
      }

      private void LoadFunctions(string script)
      {
         string line;
         ExportedTables.Clear();
         var    pattern = @"^{Verb} FUNCTION\s(.*)";
         MatchCollection matches= Regex.Matches(script, pattern, RegexOptions.Multiline | RegexOptions.IgnoreCase);
         var numFnsAct = matches.Count;

         foreach (System.Text.RegularExpressions.Match m in matches)
         { 
            //string line = $"{m.Groups[2].Value}\t\t {m.Groups[1].Value}\t\t{m.Groups[0].Value}";
            line = $"{m.Name}";

            // add game to list if not contained
            Console.WriteLine(line);
            var key = line;
            var val = line;
            ExportedTables.Add(key, val);
         }
      }

      private void LoadProcedures(string script)
      { 
         string line;
         ExportedTables.Clear();
         var    pattern = @"^{Verb} PROCEDURE\s(.*)";
         MatchCollection matches= Regex.Matches(script, pattern, RegexOptions.Multiline | RegexOptions.IgnoreCase);
         var numFnsAct = matches.Count;

         foreach (System.Text.RegularExpressions.Match m in matches)
         { 
            //string line = $"{m.Groups[2].Value}\t\t {m.Groups[1].Value}\t\t{m.Groups[0].Value}";
            line = $"{m.Name}";

            // add game to list if not contained
            Console.WriteLine(line);
            var key = line;
            var val = line;
            ExportedTables.Add(key, val);
         }
      }
*/

