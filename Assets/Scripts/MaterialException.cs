using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using UnityEngine;

namespace MaterialExceptionXML
{

    public class MaterialException
    {
        public static MaterialExtraConfigurationList CreateMaterialConfiguration(string configurationFile)
        {
            XDocument xdoc = XDocument.Load(configurationFile);

            var returnConfiguration = new MaterialExtraConfigurationList() { Materials=new List<MaterialExtraConfiguration>()};

            var materials = (from t in xdoc.Elements("Materials")
                            select t).FirstOrDefault();
            var material = (from t in materials.Elements("Material")
                        select t).ToList();

            if (material != null)
            {
                
                foreach(var m in material)
                {
                    MaterialExtraConfiguration materialExtraConfiguration = new MaterialExtraConfiguration();

                    materialExtraConfiguration.Name = m.Attribute("Name").Value;
                    materialExtraConfiguration.Throttle = m.Attribute("Throttle").Value;

                    var extraElements = (from t in m.Elements("Type")
                                        select t).ToList();

                    var extras = new List<string>();

                    foreach (var e in extraElements)
                    {
                        extras.Add(e.Value);
                    }
                    materialExtraConfiguration.MaterialName = extras;
                    returnConfiguration.Materials.Add(materialExtraConfiguration);
                }
            }

            return returnConfiguration;
        }
    }
    public class MaterialExtraConfigurationList
    {
        public List<MaterialExtraConfiguration> Materials { get; set; }
    }

    public class MaterialExtraConfiguration
    {

        public string Name { get; set; }

        public string Throttle { get; set; }

        public List<string> MaterialName { get; set; }

    }
}