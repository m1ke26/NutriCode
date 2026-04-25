// Local dictionary of ingredient descriptions for NutriCode.
//
// Keys are lowercase ingredient names matching those in
// [badIngredients] and [moderateIngredients] from ingredient_classifier.dart.
// Each value is a short, user-friendly explanation of what the ingredient is
// and why it may be concerning (or neutral).

const Map<String, String> ingredientDescriptions = {
  // ─── Harmful (bad) ────────────────────────────────────────────────

  // Sweeteners & Syrups
  'high fructose corn syrup':
      'A highly processed sweetener made from corn starch. Linked to obesity, insulin resistance, and fatty liver disease when consumed in excess.',
  'aspartame':
      'An artificial sweetener (E951) roughly 200× sweeter than sugar. Some studies raise concerns about headaches and metabolic effects, though regulatory agencies consider it safe in moderate amounts.',
  'acesulfame k':
      'An artificial sweetener (E950) often blended with other sweeteners. Some animal studies suggest it may affect gut bacteria and insulin response.',
  'acesulfame':
      'Shorthand for acesulfame potassium (E950), an artificial calorie-free sweetener. Concerns center on potential metabolic disruption.',
  'saccharin':
      'One of the oldest artificial sweeteners (E954). Once linked to cancer in lab rats, though that finding has not been replicated in humans.',
  'sucralose':
      'A chlorinated sugar derivative (E955) used as a zero-calorie sweetener. Some research suggests it may alter gut microbiome composition.',
  'neotame':
      'An extremely potent artificial sweetener (7,000–13,000× sweeter than sugar). Limited long-term human studies are available.',
  'cyclamate':
      'An artificial sweetener (E952) banned in the US but permitted in the EU. Concerns relate to potential bladder effects observed in animal studies.',
  'advantame':
      'A newer ultra-potent artificial sweetener derived from aspartame. Approved by the FDA but very limited long-term human safety data exist.',
  'stevia extract':
      'A highly refined extract from the stevia plant. Generally considered safe, though some individuals report digestive discomfort; may also affect blood pressure.',
  'steviol glycosides':
      'The purified sweet compounds from stevia leaves (E960). Considered safe by most regulators; occasionally linked to digestive issues.',
  'monk fruit extract':
      'A natural zero-calorie sweetener from luo han guo fruit. Generally well tolerated, though highly processed forms lack the nutritional value of whole fruit.',
  'alitame':
      'A synthetic peptide-based sweetener not widely approved. Very limited safety data and not permitted in many countries.',

  // Preservatives & Additives
  'sodium nitrite':
      'A preservative (E250) used in cured meats to prevent bacterial growth and maintain color. Can form nitrosamines, which are linked to increased cancer risk.',
  'sodium nitrate':
      'A preservative (E249) closely related to sodium nitrite, used in processed meats. Converts to nitrite in the body with similar health concerns.',
  'monosodium glutamate':
      'A flavor enhancer (E621) that adds umami taste. Some people report headaches or flushing ("Chinese restaurant syndrome"), though controlled studies show mixed results.',
  'msg':
      'Short for monosodium glutamate (E621). Adds savory flavor; sensitivity varies between individuals.',
  'butylated hydroxyanisole':
      'A synthetic antioxidant preservative (E320). Classified as "reasonably anticipated to be a human carcinogen" by some agencies.',
  'bha':
      'Abbreviation for butylated hydroxyanisole (E320). Used to prevent fats from going rancid; potential carcinogen.',
  'butylated hydroxytoluene':
      'A synthetic antioxidant (E321) similar to BHA. Used to preserve fats and oils; safety is debated.',
  'bht':
      'Abbreviation for butylated hydroxytoluene (E321). Prevents oxidation in packaged foods; some studies flag endocrine disruption.',
  'sodium benzoate':
      'A preservative (E211) common in acidic foods and drinks. When combined with vitamin C it can form benzene, a known carcinogen.',
  'potassium benzoate':
      'A preservative similar to sodium benzoate (E212). Shares the same benzene-formation concern in acidic conditions.',
  'benzoic acid':
      'A naturally occurring and synthetic preservative (E210). The parent compound of sodium and potassium benzoate; same benzene-formation risk in acidic foods.',
  'sodium metabisulfite':
      'A preservative and antioxidant (E223) used in dried fruits and wine. Can trigger asthma attacks and allergic reactions in sensitive individuals.',
  'potassium metabisulfite':
      'A sulfite preservative (E224) used in wine and dried foods. Similar allergen concerns to sodium metabisulfite, particularly for asthmatics.',
  'sulfur dioxide':
      'A gaseous preservative (E220) used in wine, dried fruits, and juices. Can trigger asthma and allergic reactions; must be declared on labels above 10 mg/kg.',
  'potassium bromate':
      'A flour improver banned in the EU and many countries. Classified as a possible human carcinogen (Group 2B) by the IARC.',
  'azodicarbonamide':
      'A dough conditioner and bleaching agent. Banned in the EU and Australia; breaks down into semicarbazide, a potential carcinogen.',
  'propyl paraben':
      'A preservative that can act as a weak estrogen mimic. Some countries have restricted its use in food due to endocrine disruption concerns.',
  'methyl paraben':
      'A commonly used paraben preservative (E218). Like other parabens, it can weakly mimic estrogen and is linked to endocrine disruption.',
  'ethyl paraben':
      'A paraben preservative (E214) used in beverages and sauces. Shares the same endocrine disruption concerns as other parabens.',
  'butyl paraben':
      'One of the stronger paraben preservatives in terms of estrogenic activity. Linked to reproductive and endocrine disruption in animal studies.',
  'calcium propionate':
      'A mold inhibitor (E282) widely used in bread and baked goods. Some studies suggest it may be linked to behavioral changes in children.',
  'sodium propionate':
      'A preservative (E281) used in bread and processed foods. Related to calcium propionate; similar behavioral concerns have been raised.',
  'propionic acid':
      'A naturally occurring fatty acid used as a preservative (E280). At high doses, animal studies suggest potential impacts on brain function.',
  'sorbic acid':
      'A preservative (E200) derived from mountain ash berries. Generally well tolerated but can cause skin and eye irritation in sensitive people.',
  'potassium sorbate':
      'A widely used preservative (E202) derived from sorbic acid. Can form ethyl carbamate (a potential carcinogen) when combined with ascorbic acid under certain conditions.',
  'sodium sorbate':
      'A form of sorbate preservative. Shares the same stability and potential carcinogen-formation concerns as potassium sorbate.',
  'dimethyl dicarbonate':
      'A microbial control agent (E242) used in beverages. Can form trace amounts of methanol during breakdown; permitted at low levels.',
  'sodium diacetate':
      'A preservative and flavoring agent (E262) used in snacks and bread. Generally considered safe but contributes to sodium intake.',
  'natamycin':
      'An antifungal preservative (E235) used on cheese rinds and dried meats. Some concern about promoting antimicrobial resistance.',
  'nisin':
      'A natural antimicrobial peptide (E234) derived from bacteria, used in dairy and canned foods. Generally considered low risk.',
  'tertiary butylhydroquinone':
      'A synthetic antioxidant (E319) used to preserve fats and oils. High doses have shown toxic and carcinogenic effects in animal studies.',
  'tbhq':
      'Abbreviation for tertiary butylhydroquinone (E319). Used in fried and fatty foods; associated with liver toxicity at high doses.',

  // Dyes & Colors
  'tartrazine':
      'A synthetic yellow dye (E102). Linked to hyperactivity in children and can trigger allergic reactions, especially in aspirin-sensitive individuals.',
  'red 40':
      'A widely used synthetic red dye (E129, Allura Red). Associated with hyperactivity in children and banned or restricted in several countries.',
  'yellow 5':
      'Another name for tartrazine (E102). A synthetic azo dye linked to hyperactivity and allergic reactions.',
  'yellow 6':
      'Sunset Yellow FCF (E110). A synthetic azo dye linked to hyperactivity in children and allergic reactions.',
  'blue 1':
      'Brilliant Blue FCF (E133). A synthetic dye used in beverages and sweets; generally considered low-risk but banned in some countries.',
  'blue 2':
      'Indigo carmine (E132). A synthetic dye; some concerns about allergic reactions and potential tumor promotion at very high doses.',
  'green 3':
      'Fast Green FCF (E143). A synthetic dye used primarily in the US; limited safety data compared to other approved dyes.',
  'red 3':
      'Erythrosine (E127). A cherry-red synthetic dye linked to thyroid tumors in animal studies; banned for use in cosmetics in the US but still allowed in some foods.',
  'red 2':
      'Amaranth (E123). A red azo dye banned in the US but still used in some countries. Linked to potential carcinogenicity in animal studies.',
  'red dye':
      'A general term for synthetic red colorants in food. Many red dyes (Red 40, Red 3) have been linked to behavioral issues in children.',
  'erythrosine':
      'A cherry-red synthetic dye (E127, Red 3). Linked to thyroid tumors in animal studies; restricted in many countries.',
  'brilliant blue':
      'Brilliant Blue FCF (E133). A synthetic dye used in sports drinks and confectionery; banned in some European countries.',
  'allura red':
      'Allura Red AC (E129). The same compound as Red 40; an azo dye associated with hyperactivity and potential genotoxicity.',
  'sunset yellow':
      'Sunset Yellow FCF (E110). An azo dye that, along with other Southampton dyes, has been linked to hyperactivity in children.',
  'ponceau 4r':
      'A synthetic red azo dye (E124). One of the six "Southampton dyes" linked to hyperactivity in children; banned in the US.',
  'quinoline yellow':
      'A synthetic yellow dye (E104). Another Southampton dye associated with hyperactivity in children; banned in the US and Australia.',
  'carmoisine':
      'A synthetic red azo dye (E122). Part of the Southampton six; linked to hyperactivity in children and banned in several countries.',
  'patent blue v':
      'A synthetic blue dye (E131). Can cause allergic reactions including anaphylaxis in rare cases.',
  'carmine':
      'A red pigment derived from crushed cochineal insects (E120). Can cause allergic reactions, including anaphylaxis; not suitable for vegans.',
  'titanium dioxide':
      'A white pigment (E171) used to brighten foods. Banned as a food additive in the EU since 2022 due to genotoxicity concerns.',
  'caramel colour':
      'A coloring (E150) produced by heating sugars. The Class III (E150c) and Class IV (E150d) variants can contain 4-MEI, a potential carcinogen.',
  'caramel color':
      'A coloring (E150) produced by heating sugars. The Class III and Class IV variants can contain 4-MEI, a potential carcinogen.',
  'annatto':
      'A natural orange-red dye (E160b) derived from achiote seeds. Generally safe but can trigger allergic reactions and has been linked to hyperactivity in some children.',
  'copper complexes of chlorophylls':
      'Green food colorants (E141) derived from chlorophyll. Generally safe but contain copper; not permitted in all countries.',

  // Fats & Oils
  'trans fat':
      'Industrially produced trans fats are strongly linked to heart disease. They raise LDL ("bad") cholesterol and lower HDL ("good") cholesterol.',
  'hydrogenated':
      'Hydrogenated oils are treated with hydrogen to solidify them. Full hydrogenation is less concerning, but partial hydrogenation creates harmful trans fats.',
  'partially hydrogenated':
      'The primary dietary source of industrial trans fats. Strongly associated with increased cardiovascular disease risk.',
  'partially hydrogenated oil':
      'The primary dietary source of industrial trans fats. Strongly associated with increased cardiovascular disease risk; largely banned but may still appear in trace amounts.',
  'interesterified':
      'Fats chemically modified to change their melting point, used as a trans-fat replacement. Long-term health effects are still being studied.',
  'interesterified fat':
      'Chemically restructured fat used in margarine and shortenings. Emerging research raises concerns about blood glucose and LDL cholesterol effects.',

  // Artificial & Synthetic
  'artificial sweetener':
      'A broad category of synthetic sugar substitutes (aspartame, saccharin, etc.). Concerns range from metabolic disruption to changes in gut bacteria.',
  'artificial flavour':
      'Chemically synthesized compounds that mimic natural flavors. While generally recognized as safe, they indicate a highly processed product.',
  'artificial flavor':
      'Chemically synthesized compounds that mimic natural flavors. While generally recognized as safe, they indicate a highly processed product.',
  'artificial colour':
      'Synthetic dyes used to make food look more appealing. Several have been linked to hyperactivity in children.',
  'artificial color':
      'Synthetic dyes used to make food look more appealing. Several have been linked to hyperactivity in children.',

  // Emulsifiers & Thickeners
  'propylene glycol':
      'A synthetic additive (E1520) used as a solvent, humectant, and preservative. Generally recognized as safe, but large amounts can cause lactic acidosis.',
  'polysorbate 80':
      'An emulsifier (E433) used in ice cream, sauces, and medicines. Some animal studies suggest it may promote intestinal inflammation and disrupt the gut microbiome.',
  'polysorbate 60':
      'An emulsifier (E435) similar to Polysorbate 80. Used in baked goods and desserts; shares concerns about gut microbiome disruption.',
  'polysorbate 65':
      'An emulsifier (E436) from the polysorbate family. Less studied than Polysorbate 80 but carries similar potential gut-health concerns.',
  'carrageenan':
      'A thickener (E407) extracted from seaweed. Degraded carrageenan has been linked to gut inflammation in animal studies; food-grade carrageenan remains debated.',
  'carboxymethyl cellulose':
      'A synthetic cellulose-derived emulsifier (E466). Animal studies suggest it may disrupt gut bacteria and promote intestinal inflammation.',
  'sodium carboxymethyl cellulose':
      'Also known as cellulose gum (E466). An emulsifier that some research links to increased intestinal permeability and metabolic disruption.',

  // Phosphates & Acids
  'sodium phosphate':
      'A food additive (E339) used as an emulsifier and leavening agent. Excess dietary phosphate is linked to kidney damage and cardiovascular issues.',
  'phosphoric acid':
      'An acidifier (E338) commonly used in colas. Associated with reduced bone density and kidney problems when consumed excessively.',
  'dipotassium phosphate':
      'A phosphate salt (E340ii) used as a buffering agent in coffee creamers and processed foods. Excess phosphate intake can impair kidney function.',
  'trisodium phosphate':
      'A phosphate additive (E339iii) used in cereals and processed cheese. High dietary phosphate can disrupt mineral balance and strain kidneys.',
  'sodium hexametaphosphate':
      'A polyphosphate (E452i) used as an emulsifier and sequestrant. Contributes to phosphate overload, which is linked to cardiovascular and kidney issues.',
  'sodium tripolyphosphate':
      'A phosphate preservative and emulsifier (E451i) used in seafood and meat products to retain moisture. Excess phosphate raises cardiovascular disease risk.',

  // Nitrates/Nitrites (extended)
  'potassium nitrate':
      'A preservative (E252) used in cured meats and cheese. Can be converted to nitrite in the body, with associated cancer risks similar to sodium nitrate.',
  'potassium nitrite':
      'A preservative (E249) used in some cured meats. Readily forms nitrosamines in the stomach, which are known carcinogens.',

  // Flavor Enhancers
  'disodium guanylate':
      'A flavor enhancer (E627) often used alongside MSG to amplify savory taste. Not suitable for people with gout; produced from yeast or fish.',
  'disodium inosinate':
      'A flavor enhancer (E631) derived from meat, fish, or fermentation. Works synergistically with MSG; also unsuitable for those with gout.',
  'disodium ribonucleotides':
      'A mixture of E627 and E631 (E635). Intensifies savory flavor; not suitable for gout sufferers or those avoiding animal-derived additives.',

  // E-numbers (Harmful) — references to entries above
  'e102': 'Tartrazine — a yellow azo dye linked to hyperactivity. A synthetic yellow dye (E102). Linked to hyperactivity in children and can trigger allergic reactions, especially in aspirin-sensitive individuals.',
  'e104': 'Quinoline Yellow — a Southampton dye linked to hyperactivity in children. Banned in the US.',
  'e110': 'Sunset Yellow FCF. Sunset Yellow FCF (E110). A synthetic azo dye linked to hyperactivity in children and allergic reactions.',
  'e120': 'Carmine — a red dye from cochineal insects. A red pigment derived from crushed cochineal insects (E120). Can cause allergic reactions, including anaphylaxis; not suitable for vegans.',
  'e122': 'Carmoisine — a synthetic red azo dye linked to hyperactivity. A synthetic red azo dye (E122). Part of the Southampton six; linked to hyperactivity in children and banned in several countries.',
  'e123': 'Amaranth — a red azo dye banned in the US due to carcinogenicity concerns.',
  'e124': 'Ponceau 4R — a synthetic red dye linked to hyperactivity. Banned in the US. A synthetic red azo dye (E124). One of the six "Southampton dyes" linked to hyperactivity in children; banned in the US.',
  'e127': 'Erythrosine (Red 3). A cherry-red synthetic dye (E127, Red 3). Linked to thyroid tumors in animal studies; restricted in many countries.',
  'e129': 'Allura Red AC (Red 40). A widely used synthetic red dye (E129, Allura Red). Associated with hyperactivity in children and banned or restricted in several countries.',
  'e131': 'Patent Blue V — can trigger allergic reactions. A synthetic blue dye (E131). Can cause allergic reactions including anaphylaxis in rare cases.',
  'e132': 'Indigo Carmine (Blue 2). Indigo carmine (E132). A synthetic dye; some concerns about allergic reactions and potential tumor promotion at very high doses.',
  'e133': 'Brilliant Blue FCF (Blue 1). Brilliant Blue FCF (E133). A synthetic dye used in beverages and sweets; generally considered low-risk but banned in some countries.',
  'e143': 'Fast Green FCF (Green 3). Fast Green FCF (E143). A synthetic dye used primarily in the US; limited safety data compared to other approved dyes.',
  'e150c': 'Caramel colour Class III — produced with ammonium compounds; may contain 4-MEI, a potential carcinogen.',
  'e150d': 'Caramel colour Class IV. A coloring (E150) produced by heating sugars. The Class III (E150c) and Class IV (E150d) variants can contain 4-MEI, a potential carcinogen.',
  'e160b': 'Annatto — a natural dye linked to allergic reactions. A natural orange-red dye (E160b) derived from achiote seeds. Generally safe but can trigger allergic reactions and has been linked to hyperactivity in some children.',
  'e171': 'Titanium dioxide. A white pigment (E171) used to brighten foods. Banned as a food additive in the EU since 2022 due to genotoxicity concerns.',
  'e200': 'Sorbic acid — a preservative. A preservative (E200) derived from mountain ash berries. Generally well tolerated but can cause skin and eye irritation in sensitive people.',
  'e202': 'Potassium sorbate — a widely used preservative. A widely used preservative (E202) derived from sorbic acid. Can form ethyl carbamate (a potential carcinogen) when combined with ascorbic acid under certain conditions.',
  'e210': 'Benzoic acid — a preservative that can form benzene. A naturally occurring and synthetic preservative (E210). The parent compound of sodium and potassium benzoate; same benzene-formation risk in acidic foods.',
  'e211': 'Sodium benzoate. A preservative (E211) common in acidic foods and drinks. When combined with vitamin C it can form benzene, a known carcinogen.',
  'e212': 'Potassium benzoate. A preservative similar to sodium benzoate (E212). Shares the same benzene-formation concern in acidic conditions.',
  'e218': 'Methyl paraben — a paraben preservative with endocrine disruption concerns. A commonly used paraben preservative (E218). Like other parabens, it can weakly mimic estrogen and is linked to endocrine disruption.',
  'e220': 'Sulfur dioxide — a sulfite preservative. A gaseous preservative (E220) used in wine, dried fruits, and juices. Can trigger asthma and allergic reactions; must be declared on labels above 10 mg/kg.',
  'e223': 'Sodium metabisulfite. A preservative and antioxidant (E223) used in dried fruits and wine. Can trigger asthma attacks and allergic reactions in sensitive individuals.',
  'e224': 'Potassium metabisulfite. A sulfite preservative (E224) used in wine and dried foods. Similar allergen concerns to sodium metabisulfite, particularly for asthmatics.',
  'e234': 'Nisin — an antimicrobial preservative. A natural antimicrobial peptide (E234) derived from bacteria, used in dairy and canned foods. Generally considered low risk.',
  'e235': 'Natamycin — an antifungal preservative. An antifungal preservative (E235) used on cheese rinds and dried meats. Some concern about promoting antimicrobial resistance.',
  'e242': 'Dimethyl dicarbonate — a beverage preservative. A microbial control agent (E242) used in beverages. Can form trace amounts of methanol during breakdown; permitted at low levels.',
  'e249': 'Potassium nitrite. A preservative (E249) used in some cured meats. Readily forms nitrosamines in the stomach, which are known carcinogens.',
  'e250': 'Sodium nitrite. A preservative (E250) used in cured meats to prevent bacterial growth and maintain color. Can form nitrosamines, which are linked to increased cancer risk.',
  'e252': 'Potassium nitrate. A preservative (E252) used in cured meats and cheese. Can be converted to nitrite in the body, with associated cancer risks similar to sodium nitrate.',
  'e280': 'Propionic acid — a preservative with potential brain-function concerns. A naturally occurring fatty acid used as a preservative (E280). At high doses, animal studies suggest potential impacts on brain function.',
  'e281': 'Sodium propionate — a mold inhibitor in baked goods. A preservative (E281) used in bread and processed foods. Related to calcium propionate; similar behavioral concerns have been raised.',
  'e282': 'Calcium propionate — a common bread preservative. A mold inhibitor (E282) widely used in bread and baked goods. Some studies suggest it may be linked to behavioral changes in children.',
  'e319': 'TBHQ (tertiary butylhydroquinone). Abbreviation for tertiary butylhydroquinone (E319). Used in fried and fatty foods; associated with liver toxicity at high doses.',
  'e320': 'BHA (butylated hydroxyanisole). Abbreviation for butylated hydroxyanisole (E320). Used to prevent fats from going rancid; potential carcinogen.',
  'e321': 'BHT (butylated hydroxytoluene). Abbreviation for butylated hydroxytoluene (E321). Prevents oxidation in packaged foods; some studies flag endocrine disruption.',
  'e338': 'Phosphoric acid. An acidifier (E338) commonly used in colas. Associated with reduced bone density and kidney problems when consumed excessively.',
  'e339': 'Sodium phosphate. A food additive (E339) used as an emulsifier and leavening agent. Excess dietary phosphate is linked to kidney damage and cardiovascular issues.',
  'e340': 'Potassium phosphate — a phosphate additive linked to kidney and cardiovascular concerns.',
  'e407': 'Carrageenan. A thickener (E407) extracted from seaweed. Degraded carrageenan has been linked to gut inflammation in animal studies; food-grade carrageenan remains debated.',
  'e433': 'Polysorbate 80. An emulsifier (E433) used in ice cream, sauces, and medicines. Some animal studies suggest it may promote intestinal inflammation and disrupt the gut microbiome.',
  'e435': 'Polysorbate 60. An emulsifier (E435) similar to Polysorbate 80. Used in baked goods and desserts; shares concerns about gut microbiome disruption.',
  'e436': 'Polysorbate 65. An emulsifier (E436) from the polysorbate family. Less studied than Polysorbate 80 but carries similar potential gut-health concerns.',
  'e451': 'Sodium tripolyphosphate — a phosphate emulsifier. A phosphate preservative and emulsifier (E451i) used in seafood and meat products to retain moisture. Excess phosphate raises cardiovascular disease risk.',
  'e452': 'Polyphosphates — emulsifiers. Excess phosphate intake can strain kidneys and weaken bones.',
  'e466': 'Carboxymethyl cellulose (cellulose gum). A synthetic cellulose-derived emulsifier (E466). Animal studies suggest it may disrupt gut bacteria and promote intestinal inflammation.',
  'e621': 'Monosodium glutamate (MSG). Short for monosodium glutamate (E621). Adds savory flavor; sensitivity varies between individuals.',
  'e627': 'Disodium guanylate — a flavor enhancer. A flavor enhancer (E627) often used alongside MSG to amplify savory taste. Not suitable for people with gout; produced from yeast or fish.',
  'e631': 'Disodium inosinate — a flavor enhancer. A flavor enhancer (E631) derived from meat, fish, or fermentation. Works synergistically with MSG; also unsuitable for those with gout.',
  'e635': 'Disodium ribonucleotides — a flavor enhancer. A mixture of E627 and E631 (E635). Intensifies savory flavor; not suitable for gout sufferers or those avoiding animal-derived additives.',
  'e950': 'Acesulfame potassium. An artificial sweetener (E950) often blended with other sweeteners. Some animal studies suggest it may affect gut bacteria and insulin response.',
  'e951': 'Aspartame. An artificial sweetener (E951) roughly 200× sweeter than sugar. Some studies raise concerns about headaches and metabolic effects, though regulatory agencies consider it safe in moderate amounts.',
  'e952': 'Cyclamate. An artificial sweetener (E952) banned in the US but permitted in the EU. Concerns relate to potential bladder effects observed in animal studies.',
  'e954': 'Saccharin. One of the oldest artificial sweeteners (E954). Once linked to cancer in lab rats, though that finding has not been replicated in humans.',
  'e955': 'Sucralose. A chlorinated sugar derivative (E955) used as a zero-calorie sweetener. Some research suggests it may alter gut microbiome composition.',
  'e960': 'Steviol glycosides (stevia extract). The purified sweet compounds from stevia leaves (E960). Considered safe by most regulators; occasionally linked to digestive issues.',

  // ─── Moderate ─────────────────────────────────────────────────────

  // Sugars & Sweeteners
  'sugar':
      'Refined sugar (sucrose) provides quick energy but no nutritional value. Excess consumption is linked to obesity, type 2 diabetes, and tooth decay.',
  'glucose syrup':
      'A concentrated sugar solution made from starch. Rapidly raises blood sugar levels and offers little nutritional benefit.',
  'fructose':
      'A natural fruit sugar, but in processed forms it can overload the liver and contribute to fatty liver disease when consumed in excess.',
  'sucrose':
      'Common table sugar — a 50/50 blend of glucose and fructose. Same concerns as refined sugar.',
  'dextrose':
      'A simple sugar (glucose) derived from corn. Quickly absorbed; used medically and as a food sweetener.',
  'corn syrup':
      'A liquid sweetener made from corn starch. Less sweet than high fructose corn syrup but still a significant source of added sugar.',
  'agave nectar':
      'Marketed as a natural sweetener, but very high in fructose (up to 90%). Can contribute to fatty liver and insulin resistance.',
  'agave syrup':
      'Another name for agave nectar. Despite its natural image, it is very high in fructose and can contribute to insulin resistance.',
  'honey':
      'A natural sweetener with some antioxidants and trace minerals. Still high in sugar and should be consumed in moderation.',
  'maple syrup':
      'Contains some minerals (manganese, zinc) and antioxidants, but is still largely sugar. Better than refined sugar but not "healthy" in large amounts.',
  'rice syrup':
      'A sweetener derived from rice starch. High glycemic index; may also contain trace arsenic depending on the rice source.',
  'brown rice syrup':
      'Made by fermenting cooked brown rice. Very high glycemic index, similar to glucose; may contain inorganic arsenic.',
  'coconut sugar':
      'Derived from coconut palm sap. Contains small amounts of nutrients and fiber (inulin), but is still mostly sucrose.',
  'coconut nectar':
      'The raw sap of the coconut palm flower. Similar nutritional profile to coconut sugar; still predominantly sugar.',
  'date sugar':
      'Made from dried, powdered dates. Contains fiber and trace minerals, but is still a concentrated source of sugar.',
  'date syrup':
      'A thick syrup made from whole dates. Contains small amounts of potassium and antioxidants but is still high in sugar.',
  'molasses':
      'A by-product of sugar refining that retains iron, calcium, and potassium. Nutritionally superior to white sugar but still high in sugar content.',
  'blackstrap molasses':
      'The most mineral-rich form of molasses, containing significant iron, calcium, and magnesium. Still high in sugar, but the most nutritious of the syrups.',
  'maltitol':
      'A sugar alcohol with about 75% of sugar\'s sweetness and fewer calories. Can cause digestive discomfort (bloating, diarrhea) in large amounts.',
  'erythritol':
      'A sugar alcohol with almost zero calories. Generally well tolerated but recent research has raised questions about cardiovascular markers at very high intakes.',
  'xylitol':
      'A sugar alcohol that is beneficial for dental health (reduces cavity-causing bacteria). Can cause digestive upset and is toxic to dogs.',
  'sorbitol':
      'A sugar alcohol (E420) naturally found in some fruits. Fewer calories than sugar but can cause bloating, gas, and diarrhea in large amounts.',
  'mannitol':
      'A sugar alcohol (E421) used as a sweetener and anti-caking agent. Can have a laxative effect when consumed in large quantities.',
  'isomalt':
      'A sugar alcohol (E953) derived from sucrose. Lower glycemic impact than sugar but can cause digestive issues at high doses.',
  'lactitol':
      'A sugar alcohol (E966) derived from lactose. Used in sugar-free products; can cause bloating and has a laxative effect in excess.',
  'invert sugar':
      'A mixture of equal parts glucose and fructose produced by splitting sucrose. Sweeter than regular sugar; used in confectionery to prevent crystallization.',
  'treacle':
      'A British term for syrup by-products of sugar refining. Similar to molasses; high in sugar with some trace minerals.',
  'golden syrup':
      'A refined sugar syrup by-product. Very high in sugar with negligible nutritional value beyond calories.',
  'barley malt syrup':
      'A natural sweetener made from malted barley. Contains some minerals and B vitamins, but is still predominantly maltose sugar.',
  'malt extract':
      'A concentrated syrup made from malted barley. Provides some B vitamins but is still a significant source of simple sugars.',

  // Salts
  'salt':
      'Essential for bodily functions, but most people consume far more than needed. Excess salt is strongly linked to high blood pressure and cardiovascular disease.',
  'sodium':
      'The main component of salt. Recommended daily intake is less than 2,300 mg; exceeding this can raise blood pressure.',
  'sea salt':
      'Chemically almost identical to table salt. May contain trace minerals, but the health difference from regular salt is negligible.',
  'rock salt':
      'Unrefined salt mined from underground deposits. Nutritionally equivalent to table salt; same cardiovascular concerns apply.',
  'himalayan pink salt':
      'A mineral-rich rock salt with a pink hue. Contains trace minerals, but the health benefits over regular salt are largely overstated.',
  'kosher salt':
      'A coarse-grained salt with no additives. Chemically equivalent to table salt; the same sodium intake concerns apply.',
  'celery salt':
      'A blend of ground dried celery and salt. Adds flavor but contributes to sodium intake; sodium concerns are the same as table salt.',
  'onion salt':
      'A blend of onion powder and salt. Adds flavor but is a significant sodium source.',
  'garlic salt':
      'A blend of garlic powder and salt. Same sodium concerns as other flavored salts.',
  'monosodium glutamate (msg)':
      'A sodium-based flavor enhancer. Adds savory taste and contributes to sodium intake; some individuals report sensitivity symptoms.',
  'sodium bicarbonate':
      'Baking soda (E500). Used as a leavening agent; contributes to sodium intake but generally used in small amounts.',
  'baking soda':
      'Common name for sodium bicarbonate. A leavening agent that contributes modest sodium; generally safe in normal baking quantities.',
  'baking powder':
      'A leavening agent containing sodium bicarbonate, acid (cream of tartar or sodium phosphate), and starch. Contributes sodium and phosphate.',

  // Oils & Fats
  'palm oil':
      'High in saturated fat. Its large-scale production is a major driver of deforestation and biodiversity loss in tropical regions.',
  'palm kernel oil':
      'Extracted from the seed of the palm fruit. Even higher in saturated fat than palm oil; same deforestation concerns.',
  'sunflower oil':
      'Rich in vitamin E but high in omega-6 fatty acids. Excess omega-6 relative to omega-3 can promote inflammation.',
  'high oleic sunflower oil':
      'A variety of sunflower oil bred to be higher in monounsaturated fat (oleic acid). More heat-stable and a healthier fatty acid profile than standard sunflower oil.',
  'rapeseed oil':
      'Also known as canola oil. Has a favorable fatty acid profile (low in saturated fat, good omega-3 content). Generally considered a healthy cooking oil.',
  'vegetable oil':
      'A vague term that can refer to various oils (soy, palm, sunflower). Quality and health impact depend on the specific oil used.',
  'canola oil':
      'A refined form of rapeseed oil with low saturated fat and a good omega-3 to omega-6 ratio. Considered one of the healthier cooking oils.',
  'soybean oil':
      'High in polyunsaturated fats including omega-6. Widely used in processed foods; excess omega-6 intake may promote inflammation.',
  'corn oil':
      'Extracted from maize germ. High in omega-6 fatty acids; large amounts may contribute to an imbalanced omega-3 to omega-6 ratio.',
  'cottonseed oil':
      'Derived from cotton plant seeds. High in saturated and omega-6 fats; may contain residues of pesticides unless refined.',
  'coconut oil':
      'Very high in saturated fat (~90%). Controversial: some research suggests its saturated fats may be metabolized differently, but major health bodies still advise moderation.',
  'shea butter':
      'A fat extracted from shea tree nuts. High in oleic and stearic acids. Used in chocolate alternatives; generally considered safe.',
  'cocoa butter':
      'The natural fat extracted from cocoa beans. High in stearic acid, which does not raise LDL cholesterol. Considered a relatively heart-neutral fat.',
  'lard':
      'Rendered pig fat. High in saturated fat and cholesterol. Better than trans fats but should be consumed in moderation.',
  'beef tallow':
      'Rendered beef fat. High in saturated fat. Similar concerns to lard; may be preferable to some vegetable shortenings but should be eaten in moderation.',
  'ghee':
      'Clarified butter with milk solids removed. High in saturated fat; contains fat-soluble vitamins. Should be consumed in moderation.',
  'butter':
      'A dairy fat high in saturated fat and cholesterol. Contains fat-soluble vitamins; fine in moderation but should be limited in large amounts.',
  'margarine':
      'A butter substitute often made from vegetable oils. Modern formulations are trans-fat free, but check the label; older or cheaper versions may contain hydrogenated oils.',
  'shortening':
      'A solid fat used in baking. Many shortenings have been reformulated to remove trans fats, but may still be high in saturated fat.',
  'mineral oil':
      'A petroleum-derived oil used in some food coatings and as a release agent. Can interfere with absorption of fat-soluble vitamins with frequent use.',
  'rice bran oil':
      'Oil extracted from the outer layer of rice. Has a balanced fatty acid profile and contains gamma-oryzanol, which may help lower cholesterol.',
  'flaxseed oil':
      'Very high in alpha-linolenic acid (ALA), a plant-based omega-3 fatty acid. Beneficial for heart health but should not be used for cooking as it oxidizes easily.',
  'sesame oil':
      'Rich in polyunsaturated and monounsaturated fats plus antioxidants (sesamol). Considered a heart-healthy oil when used in moderation.',
  'peanut oil':
      'A high-heat cooking oil with a balanced fat profile. Contains vitamin E; generally considered healthy but is an allergen for those with peanut allergy.',
  'avocado oil':
      'High in heart-healthy monounsaturated fats (oleic acid) and vitamin E. One of the healthiest cooking oils with a high smoke point.',
  'olive oil':
      'Rich in monounsaturated fats and antioxidants (polyphenols). Strongly associated with heart health benefits; best used unheated or at low temperatures.',

  // Starches & Maltodextrins
  'maltodextrin':
      'A highly processed starch-derived powder. Has a very high glycemic index (higher than table sugar) and can spike blood sugar rapidly.',
  'modified starch':
      'Starch that has been physically, enzymatically, or chemically altered to change its properties. Generally safe but indicates processing.',
  'corn starch':
      'A common thickener made from corn. Low nutritional value; mainly pure carbohydrate.',
  'potato starch':
      'A gluten-free thickener extracted from potatoes. Nutritionally similar to corn starch — mostly empty carbohydrate.',
  'tapioca starch':
      'Extracted from cassava root. Gluten-free and easy to digest, but provides almost no vitamins or minerals.',
  'wheat starch':
      'A refined starch from wheat with most of the gluten removed. Not always safe for people with celiac disease depending on residual gluten levels.',
  'rice starch':
      'A fine-textured starch from rice. Gluten-free and highly digestible; low nutritional value.',
  'arrowroot':
      'A starch extracted from the arrowroot plant. Gluten-free, easily digestible, and considered one of the gentler starches for the digestive system.',
  'dextrin':
      'A partially hydrolyzed starch used as a thickener, binder, or encapsulant. Has a moderate glycemic index; generally safe.',
  'cyclodextrin':
      'A modified starch (E459) used to encapsulate flavors and stabilize ingredients. Generally recognized as safe in small amounts.',

  // Dairy & Proteins
  'skim milk powder':
      'Dehydrated skimmed milk. Adds protein and calcium but also lactose; not suitable for those with lactose intolerance.',
  'whey powder':
      'A by-product of cheese production. High in protein; not suitable for people with dairy allergies.',
  'whey protein':
      'A concentrated dairy protein popular in sports nutrition. High biological value protein; can cause digestive issues in lactose-intolerant individuals.',
  'casein':
      'The primary protein in milk. Slow-digesting; can cause reactions in those with dairy or casein sensitivity.',
  'sodium caseinate':
      'A form of casein used as an emulsifier and protein source. Not suitable for those with dairy allergies.',
  'calcium caseinate':
      'A calcium salt of casein used in protein products and coffee creamers. Dairy-derived; not suitable for vegans or those with dairy allergies.',
  'milk solids':
      'The non-fat dried components of milk (proteins, lactose, minerals). Adds dairy flavor and protein; contains lactose.',
  'lactose':
      'The natural sugar found in milk. Causes digestive problems (bloating, gas, diarrhea) in people who are lactose intolerant.',
  'lactalbumin':
      'A whey protein found in milk. Highly digestible; can trigger reactions in those with dairy allergies.',
  'egg white powder':
      'Dehydrated egg whites. High in protein and albumin. A common allergen; not suitable for vegans or those with egg allergies.',
  'egg yolk powder':
      'Dehydrated egg yolks. Contains protein, fat, and choline. An allergen; not suitable for vegans or those with egg allergies.',
  'whole egg powder':
      'Dehydrated whole eggs. A common allergen with a high protein and fat content.',
  'soy protein':
      'A plant-based protein extracted from soybeans. A common allergen; often used in meat substitutes and protein powders.',
  'soy protein isolate':
      'A highly refined form of soy protein (90%+ protein content). Common allergen; highly processed.',
  'soy protein concentrate':
      'Soy protein with most sugars removed (65–70% protein). A common allergen; less refined than isolate.',
  'pea protein':
      'A plant-based protein derived from yellow split peas. Generally hypoallergenic and well tolerated; a good vegan protein source.',
  'rice protein':
      'Protein extracted from brown rice. Hypoallergenic and vegan-friendly; typically lower in lysine than animal proteins.',
  'hydrolysed vegetable protein':
      'Protein that has been broken down by heat or enzymes. Used as a flavor enhancer; naturally contains glutamates similar to MSG.',
  'hydrolyzed vegetable protein':
      'Protein that has been broken down by heat or enzymes. Used as a flavor enhancer; naturally contains glutamates similar to MSG.',
  'textured vegetable protein':
      'Defatted soy flour processed into a meat-like texture. Used in vegetarian meat substitutes. A soy allergen; highly processed.',
  'tvp':
      'Short for textured vegetable protein. Defatted soy flour processed into a meat-like texture. Used in vegetarian meat substitutes. A soy allergen; highly processed.',
  'gelatin':
      'A protein derived from animal collagen (bones and skin). Used as a gelling agent. Not suitable for vegetarians or vegans.',

  // Acids
  'citric acid':
      'A natural acid (E330) found in citrus fruits. Used as a preservative and flavoring agent. Generally harmless; very rarely may erode tooth enamel.',
  'malic acid':
      'An organic acid found in apples and other fruits. Used to add tartness. Considered safe.',
  'ascorbic acid':
      'Vitamin C (E300). Used as an antioxidant and preservative. Beneficial in appropriate amounts.',
  'lactic acid':
      'Naturally produced during fermentation. Used as a preservative and pH regulator. Generally safe and well tolerated.',
  'tartaric acid':
      'A natural acid (E334) found in grapes. Used as an acidulant in wine and baking powder. Generally safe; overconsumption can cause digestive upset.',
  'acetic acid':
      'The main component of vinegar (E260). Used as a preservative and flavoring agent. Considered safe; may cause irritation in very high concentrations.',
  'gluconic acid':
      'An organic acid (E574) derived from glucose fermentation. Used as a leavening agent and sequestrant. Generally considered safe.',
  'fumaric acid':
      'An organic acid (E297) used as an acidulant in beverages, bread, and wine. Generally safe at food-use levels.',
  'adipic acid':
      'An organic acid (E355) used as an acidulant and buffering agent in desserts and drinks. Generally considered safe in food amounts.',

  // Leavening Agents
  'cream of tartar':
      'Potassium bitartrate (E336) — a natural by-product of winemaking. Used as a leavening agent and stabilizer. Generally safe.',
  'sodium acid pyrophosphate':
      'A leavening agent (E450i). Contributes to dietary phosphate intake; concerns about excess phosphate apply at high consumption levels.',
  'monocalcium phosphate':
      'A leavening acid (E341i) used in baking powder. Contributes phosphate to the diet; generally safe in normal baking amounts.',
  'ammonium bicarbonate':
      'A leavening agent (E503ii) used in cookies and crackers. Breaks down completely during baking, leaving no residue; generally safe.',
  'calcium carbonate':
      'A mineral supplement and anti-caking agent (E170). Also used as a calcium fortifier. Generally safe and beneficial in appropriate amounts.',
  'potassium carbonate':
      'An alkaline agent (E501i) used in cocoa processing and noodle making. Generally safe in food amounts.',

  // Flavorings
  'natural flavour':
      'Derived from natural sources (plants, animals, fermentation) but still processed. "Natural" does not necessarily mean healthier.',
  'natural flavor':
      'Derived from natural sources (plants, animals, fermentation) but still processed. "Natural" does not necessarily mean healthier.',
  'natural flavouring':
      'Derived from natural sources. Minimally processed flavors extracted from herbs, spices, or fermentation. Generally safe but may mask low-quality ingredients.',
  'natural flavoring':
      'Derived from natural sources. A catch-all term that still allows significant processing; "natural" does not guarantee a whole-food ingredient.',
  'flavouring':
      'A broad term covering both natural and artificial flavoring compounds. Its presence usually indicates a processed product.',
  'flavoring':
      'A broad term covering both natural and artificial flavoring compounds. Its presence usually indicates a processed product.',
  'yeast extract':
      'A flavor enhancer rich in glutamates (similar to MSG). Often used in "clean label" products as a natural alternative to MSG.',
  'autolyzed yeast':
      'Yeast whose cell walls have been broken down, releasing their contents including glutamates. Adds savory flavor similarly to MSG.',
  'hydrolysed yeast':
      'Yeast protein broken down by enzymes or acids. Rich in free glutamates and used as a natural flavor enhancer.',
  'smoke flavour':
      'Liquid smoke or smoke flavoring used to impart a smoky taste. May contain polycyclic aromatic hydrocarbons (PAHs), some of which are carcinogenic.',
  'smoke flavor':
      'Liquid smoke or smoke flavoring. May contain PAHs depending on production method; generally used in small amounts.',
  'vanilla extract':
      'Extracted from vanilla beans in alcohol. Contains antioxidants and is generally safe; a natural and beneficial flavoring.',
  'vanillin':
      'A synthetic compound that replicates vanilla flavor (E903 in some uses). Generally safe; cheaper than real vanilla extract.',
  'ethyl vanillin':
      'A synthetic analog of vanillin with a stronger vanilla flavor. Generally considered safe; more potent than vanillin.',
  'diacetyl':
      'A compound that gives a buttery flavor. Used in microwave popcorn and flavorings. Linked to serious lung disease ("popcorn lung") in factory workers who inhale it; risk from eating is considered very low.',

  // Gums & Thickeners
  'xanthan gum':
      'A polysaccharide (E415) produced by bacterial fermentation. Widely used as a thickener. Generally well tolerated; large amounts may cause bloating.',
  'guar gum':
      'A fiber from guar beans (E412) used as a thickener. Can cause digestive discomfort in large quantities.',
  'locust bean gum':
      'Also called carob gum (E410). A natural thickener extracted from carob seeds. Generally considered safe.',
  'pectin':
      'A natural fiber (E440) found in fruit cell walls. Used as a gelling agent in jams. Considered safe and may even support gut health.',
  'agar':
      'A plant-based gelling agent derived from seaweed (E406). Vegan-friendly alternative to gelatin. Considered safe.',
  'agar-agar':
      'Same as agar (E406). A seaweed-derived gelling agent. Vegan, generally safe, and may have mild cholesterol-lowering properties.',
  'gellan gum':
      'A microbial polysaccharide (E418) used as a thickener and gelling agent. Generally considered safe; used in plant-based milks.',
  'konjac':
      'A plant-based thickener (E425) derived from konjac root. Very high in glucomannan fiber; beneficial for blood sugar and gut health but can cause choking if swallowed in large pieces.',
  'konjac gum':
      'The gum form of konjac (E425i). High in soluble fiber; beneficial for digestive health and blood sugar control.',
  'methylcellulose':
      'A chemically modified plant fiber (E461) used as a thickener and fat replacer. Not absorbed by the body; acts as a bulking fiber.',
  'hydroxypropyl methylcellulose':
      'A semi-synthetic cellulose derivative (E464). Used as a thickener and film-forming agent; not absorbed by the body.',
  'hydroxypropyl cellulose':
      'A cellulose derivative (E463) used in coatings and as a thickener. Considered safe; not absorbed by the body.',
  'microcrystalline cellulose':
      'Refined plant fiber (E460i) used as an anti-caking agent and fat replacer. Generally safe; provides no caloric value.',
  'sodium alginate':
      'An algae-derived gelling agent (E401). Generally safe and widely used in food manufacturing and molecular gastronomy.',
  'potassium alginate':
      'Similar to sodium alginate (E402). Used as a thickener and stabilizer. Generally considered safe.',
  'calcium alginate':
      'An alginate salt (E404) used to create gels and encapsulate foods. Generally safe.',
  'arabic gum':
      'Also called acacia gum (E414). A natural fiber from acacia trees. Generally safe; acts as a prebiotic fiber.',
  'acacia gum':
      'Same as arabic gum (E414). A soluble dietary fiber with prebiotic properties. Generally safe and well tolerated.',
  'tara gum':
      'A natural thickener (E417) from the tara tree. Generally considered safe; limited research compared to other gums.',
  'cassia gum':
      'A thickener (E499) from cassia seeds. Generally safe for humans but can cause liver problems in pets.',
  'cellulose gum':
      'Common name for carboxymethyl cellulose (E466). A synthetic cellulose-derived emulsifier (E466). Animal studies suggest it may disrupt gut bacteria and promote intestinal inflammation.',

  // Emulsifiers & Others
  'emulsifier':
      'A substance that helps mix oil and water (e.g., lecithin, mono- and diglycerides). Some synthetic emulsifiers may affect gut lining integrity.',
  'stabiliser':
      'An additive that maintains texture and consistency. Covers a broad range of substances with varying safety profiles.',
  'stabilizer':
      'An additive that maintains texture and consistency. Covers a broad range of substances with varying safety profiles.',
  'thickener':
      'Substances that increase viscosity (e.g., starches, gums). Generally safe but indicate a processed product.',
  'acidity regulator':
      'Additives that control the pH of food (e.g., citric acid, lactic acid). Usually safe and often naturally derived.',
  'anti-caking agent':
      'Prevents powders from clumping (e.g., silicon dioxide, magnesium carbonate). Generally inert and used in tiny amounts.',
  'preservative':
      'A broad category of additives that extend shelf life. Safety varies widely depending on the specific preservative used.',
  'lecithin':
      'A natural emulsifier (E322) typically derived from soy or sunflower. Generally safe and may support cell membrane health.',
  'soy lecithin':
      'Lecithin derived specifically from soybeans (E322). Generally safe; may be an allergen for people with severe soy allergy, though most soy proteins are removed in processing.',
  'sunflower lecithin':
      'Lecithin extracted from sunflower seeds. A common soy-free alternative emulsifier. Generally well tolerated.',
  'mono- and diglycerides':
      'Emulsifiers (E471) made from fatty acids. Common in bread and baked goods. Considered safe by most regulatory bodies.',
  'monoglycerides':
      'A component of E471 emulsifiers. Used to improve texture in baked goods. Generally recognized as safe.',
  'diglycerides':
      'A component of E471 emulsifiers. Used alongside monoglycerides to stabilize food products.',
  'acetylated mono- and diglycerides':
      'Modified emulsifiers (E472a) used to improve texture in baked goods. Generally considered safe.',
  'lactic acid esters':
      'Emulsifiers (E472b) made from lactic acid and fatty acids. Used in whipped products and bread. Generally safe.',
  'citric acid esters':
      'Emulsifiers (E472c) used in margarines and dressings. Generally considered safe.',
  'diacetyltartaric acid esters':
      'DATEM (E472e) — an emulsifier used in bread to improve dough strength. Generally safe.',
  'datem':
      'Diacetyl tartaric acid esters of mono- and diglycerides (E472e). A common bread emulsifier. Generally considered safe.',
  'sucrose esters':
      'Emulsifiers (E473) made from sucrose and fatty acids. Generally safe; used in low-fat products.',
  'polyglycerol esters':
      'Emulsifiers (E475) used in chocolate and bakery products. Generally considered safe.',
  'sorbitan monostearate':
      'An emulsifier (E491) used in yeast foods and chocolate coatings. Generally safe; related to polysorbates.',
  'sorbitan tristearate':
      'An emulsifier (E492) used in chocolate and confectionery. Generally considered safe.',
  'ammonium phosphatides':
      'Emulsifiers (E442) used in chocolate as an alternative to lecithin. Generally considered safe.',
  'stearoyl lactylates':
      'Emulsifiers (sodium stearoyl lactylate, E481; calcium stearoyl lactylate, E482) used in bread and baked goods. Generally safe; derived from lactic acid and stearic acid.',
  'sodium stearoyl lactylate':
      'An emulsifier (E481) used in bread, cereal, and other baked goods to improve texture and shelf life. Generally considered safe.',
  'calcium stearoyl lactylate':
      'An emulsifier (E482) similar to sodium stearoyl lactylate. Used in baked goods; generally considered safe.',

  // Antioxidants
  'vitamin e':
      'A fat-soluble antioxidant (E306–E309) used to prevent rancidity in oils and fats. Beneficial in food amounts; high-dose supplements can have risks.',
  'tocopherol':
      'The chemical name for vitamin E (E306). Used as a natural antioxidant in foods. Generally beneficial.',
  'mixed tocopherols':
      'A blend of vitamin E forms (E306) used as an antioxidant in fats and oils. Natural and generally safe.',
  'alpha-tocopherol':
      'The most biologically active form of vitamin E (E307). Used as an antioxidant. Generally safe and beneficial.',
  'rosemary extract':
      'A natural plant-derived antioxidant. Used to prevent rancidity in fats and oils. Generally safe and may have health benefits.',
  'ascorbyl palmitate':
      'A fat-soluble form of vitamin C (E304) used as an antioxidant. Generally safe, though some studies suggest very high doses can act as a pro-oxidant.',

  // Minerals & Vitamins (fortification)
  'iron':
      'An essential mineral added to fortify cereals and breads. Necessary for health; fortification helps prevent anemia but should be from whole food sources when possible.',
  'zinc':
      'An essential trace mineral added to some fortified foods. Necessary for immune function; generally safe in food amounts.',
  'calcium':
      'An essential mineral for bone health. Often added to plant-based milks and fortified foods. Generally safe and beneficial.',
  'niacin':
      'Vitamin B3, added to fortified cereals and breads. Essential for energy metabolism. Generally safe at food fortification levels.',
  'thiamin':
      'Vitamin B1, used in fortified cereals and flours. Essential for nerve and muscle function. Generally safe.',
  'thiamine':
      'Another spelling of thiamin (Vitamin B1). Essential nutrient; generally safe at food levels.',
  'riboflavin':
      'Vitamin B2 (E101), also used as a natural yellow food color. Essential for energy production; generally safe.',
  'folic acid':
      'The synthetic form of folate (Vitamin B9). Used in fortified foods and supplements. Essential for cell growth; very important in pregnancy.',
  'folate':
      'The natural form of Vitamin B9 found in foods. Essential for DNA synthesis and cell division; especially important during pregnancy.',
  'vitamin b6':
      'Pyridoxine, added to some fortified foods. Essential for protein metabolism and brain function. Safe at food levels; excess supplementation can cause nerve damage.',
  'vitamin b12':
      'Cobalamin, often added to plant-based products and fortified cereals. Essential for nerve function; deficiency is common in vegans.',
  'vitamin d':
      'A fat-soluble vitamin (D2 or D3) often added to dairy and plant-based milks. Essential for bone health and immune function.',
  'vitamin d2':
      'Ergocalciferol — a plant-derived form of vitamin D. Used to fortify foods; somewhat less effective than D3 at raising blood levels.',
  'vitamin d3':
      'Cholecalciferol — the animal-derived form of vitamin D. The most effective form for fortification; generally from fish oil or lanolin.',
  'vitamin a':
      'A fat-soluble vitamin (retinol or beta-carotene) added to some margarines and cereals. Essential for vision and immunity; excess preformed vitamin A can be toxic.',

  // Humectants
  'glycerol':
      'Also known as glycerin (E422). A humectant that retains moisture in foods. Generally safe; naturally derived from fats or produced synthetically.',
  'glycerin':
      'Another name for glycerol (E422). Used as a sweetener and moisture retainer. Generally safe in food amounts.',

  // Bulking Agents & Fiber
  'inulin':
      'A naturally occurring prebiotic fiber found in chicory root, onions, and garlic. Supports gut health and feeds beneficial bacteria; large amounts may cause gas and bloating.',
  'chicory root':
      'A source of inulin fiber. Commonly added to foods to increase fiber content. Generally safe; may cause digestive discomfort in large amounts.',
  'chicory root fiber':
      'Inulin extracted from chicory root. Acts as a prebiotic fiber. A naturally occurring prebiotic fiber found in chicory root, onions, and garlic. Supports gut health and feeds beneficial bacteria; large amounts may cause gas and bloating.',
  'chicory root extract':
      'Concentrated inulin from chicory root. Prebiotic properties; same digestive caveats as inulin apply.',
  'fructooligosaccharides':
      'Short-chain fructose polymers (FOS) that act as prebiotic fiber. Support gut health; may cause gas and bloating in large amounts.',
  'fos':
      'Abbreviation for fructooligosaccharides. Short-chain fructose polymers (FOS) that act as prebiotic fiber. Support gut health; may cause gas and bloating in large amounts.',
  'galactooligosaccharides':
      'Prebiotic fibers (GOS) derived from lactose. Support gut health and beneficial bacteria; generally well tolerated.',
  'gos':
      'Abbreviation for galactooligosaccharides. Prebiotic fibers (GOS) derived from lactose. Support gut health and beneficial bacteria; generally well tolerated.',
  'resistant starch':
      'Starch that resists digestion in the small intestine and acts like fiber. Beneficial for gut health and blood sugar control.',
  'oat fiber':
      'A type of dietary fiber derived from oat husks. High in beta-glucan; beneficial for cholesterol levels and gut health.',
  'wheat fiber':
      'Insoluble fiber from wheat bran. Supports digestive regularity; not suitable for those with celiac disease or gluten sensitivity.',
  'pea fiber':
      'Dietary fiber extracted from peas. A good source of soluble and insoluble fiber. Generally well tolerated and beneficial.',
  'apple fiber':
      'Fiber derived from apple pomace. Contains pectin and other beneficial compounds. Generally safe and nutritious.',
  'psyllium husk':
      'A soluble fiber from the seeds of Plantago ovata. Highly effective for improving cholesterol and digestive regularity. Can cause choking if not taken with sufficient water.',
  'cellulose':
      'A plant-derived insoluble fiber (E460) used as an anti-caking agent or bulking agent. Not digested; generally safe and adds bulk to processed foods.',

  // Anti-caking & Processing Aids
  'silicon dioxide':
      'A naturally occurring mineral (E551) used as an anti-caking agent in powders. Generally considered inert and safe; nanoparticle forms are under further study.',
  'magnesium carbonate':
      'An anti-caking agent (E504). Generally considered safe; also used as a magnesium supplement.',
  'calcium silicate':
      'An anti-caking agent (E552). Considered safe; used in table salt and baking powder.',
  'magnesium stearate':
      'A salt of stearic acid (E572). Used as an anti-caking and release agent. Generally safe in the small amounts found in food.',
  'sodium ferrocyanide':
      'An anti-caking agent (E535) used in table salt. Despite its chemical name, it is non-toxic at permitted levels and does not release cyanide under normal conditions.',
  'potassium ferrocyanide':
      'An anti-caking agent (E536) similar to sodium ferrocyanide. Non-toxic at food-use levels.',
  'tricalcium phosphate':
      'An anti-caking agent and calcium supplement (E341iii). Generally safe; contributes to calcium intake.',
  'kaolin':
      'A type of clay (E559) used as an anti-caking agent. Considered safe in the very small amounts used in food.',

  // Glazing & Wax Coatings
  'carnauba wax':
      'A natural wax from palm leaves (E903) used to coat candies, fruits, and tablets. Generally considered safe.',
  'beeswax':
      'A natural wax (E901) used to coat candies and fruits. Generally safe; not suitable for vegans.',
  'shellac':
      'A resin secreted by the lac beetle (E904) used as a glaze on candies and fruits. Generally safe; not suitable for vegans.',
  'paraffin wax':
      'A petroleum-derived wax (E905) used as a coating on fruits and confectionery. Generally considered safe in the small amounts used for coating.',

  // Carbonation
  'carbon dioxide':
      'The gas (E290) used to carbonate beverages. Creates carbonation; considered safe. Excess consumption of carbonated drinks is linked to tooth erosion.',

  // E-numbers (Moderate)
  'e101': 'Riboflavin (Vitamin B2) — a natural yellow color and essential vitamin. Vitamin B2 (E101), also used as a natural yellow food color. Essential for energy production; generally safe.',
  'e160a': 'Beta-carotene — a natural orange-yellow pigment that is a precursor to Vitamin A. Generally safe and beneficial.',
  'e163': 'Anthocyanins — natural pigments from berries and red cabbage. Act as antioxidants; generally safe.',
  'e170': 'Calcium carbonate — a mineral used as a color and anti-caking agent. A mineral supplement and anti-caking agent (E170). Also used as a calcium fortifier. Generally safe and beneficial in appropriate amounts.',
  'e260': 'Acetic acid (vinegar). The main component of vinegar (E260). Used as a preservative and flavoring agent. Considered safe; may cause irritation in very high concentrations.',
  'e270': 'Lactic acid. Naturally produced during fermentation. Used as a preservative and pH regulator. Generally safe and well tolerated.',
  'e296': 'Malic acid. An organic acid found in apples and other fruits. Used to add tartness. Considered safe.',
  'e297': 'Fumaric acid. An organic acid (E297) used as an acidulant in beverages, bread, and wine. Generally safe at food-use levels.',
  'e300': 'Ascorbic acid (Vitamin C). An antioxidant. Considered beneficial.',
  'e301': 'Sodium ascorbate — a buffered form of Vitamin C. Generally safe and beneficial.',
  'e302': 'Calcium ascorbate — a buffered form of Vitamin C with added calcium. Generally safe.',
  'e304': 'Ascorbyl palmitate — a fat-soluble Vitamin C derivative. A fat-soluble form of vitamin C (E304) used as an antioxidant. Generally safe, though some studies suggest very high doses can act as a pro-oxidant.',
  'e306': 'Mixed tocopherols (Vitamin E). A natural antioxidant. The chemical name for vitamin E (E306). Used as a natural antioxidant in foods. Generally beneficial.',
  'e307': 'Alpha-tocopherol (Vitamin E). The most biologically active form of vitamin E (E307). Used as an antioxidant. Generally safe and beneficial.',
  'e322': 'Lecithin. A natural emulsifier, usually from soy or sunflower. Generally safe.',
  'e330': 'Citric acid. A naturally occurring acid used as a preservative and flavor enhancer.',
  'e331': 'Sodium citrates — salts of citric acid used as buffering agents. Generally safe.',
  'e332': 'Potassium citrates — used as buffering and emulsifying agents. Generally safe.',
  'e334': 'Tartaric acid. A natural acid (E334) found in grapes. Used as an acidulant in wine and baking powder. Generally safe; overconsumption can cause digestive upset.',
  'e336': 'Cream of tartar (potassium bitartrate). Potassium bitartrate (E336) — a natural by-product of winemaking. Used as a leavening agent and stabilizer. Generally safe.',
  'e341': 'Calcium phosphates — leavening agents and mineral supplements. Generally safe.',
  'e401': 'Sodium alginate — a seaweed-derived thickener. An algae-derived gelling agent (E401). Generally safe and widely used in food manufacturing and molecular gastronomy.',
  'e406': 'Agar — a seaweed-derived gelling agent. A plant-based gelling agent derived from seaweed (E406). Vegan-friendly alternative to gelatin. Considered safe.',
  'e410': 'Locust bean gum. Also called carob gum (E410). A natural thickener extracted from carob seeds. Generally considered safe.',
  'e412': 'Guar gum. A fiber from guar beans (E412) used as a thickener. Can cause digestive discomfort in large quantities.',
  'e414': 'Arabic gum (acacia gum). Also called acacia gum (E414). A natural fiber from acacia trees. Generally safe; acts as a prebiotic fiber.',
  'e415': 'Xanthan gum. A polysaccharide (E415) produced by bacterial fermentation. Widely used as a thickener. Generally well tolerated; large amounts may cause bloating.',
  'e418': 'Gellan gum. A microbial polysaccharide (E418) used as a thickener and gelling agent. Generally considered safe; used in plant-based milks.',
  'e420': 'Sorbitol — a sugar alcohol. A sugar alcohol (E420) naturally found in some fruits. Fewer calories than sugar but can cause bloating, gas, and diarrhea in large amounts.',
  'e421': 'Mannitol — a sugar alcohol. A sugar alcohol (E421) used as a sweetener and anti-caking agent. Can have a laxative effect when consumed in large quantities.',
  'e422': 'Glycerol (glycerin). Also known as glycerin (E422). A humectant that retains moisture in foods. Generally safe; naturally derived from fats or produced synthetically.',
  'e440': 'Pectin. A natural gelling agent from fruit. A natural fiber (E440) found in fruit cell walls. Used as a gelling agent in jams. Considered safe and may even support gut health.',
  'e460': 'Cellulose — plant-derived fiber used as a bulking agent. A plant-derived insoluble fiber (E460) used as an anti-caking agent or bulking agent. Not digested; generally safe and adds bulk to processed foods.',
  'e461': 'Methylcellulose — a semi-synthetic thickener. A chemically modified plant fiber (E461) used as a thickener and fat replacer. Not absorbed by the body; acts as a bulking fiber.',
  'e464': 'Hydroxypropyl methylcellulose (HPMC). A semi-synthetic cellulose derivative (E464). Used as a thickener and film-forming agent; not absorbed by the body.',
  'e471': 'Mono- and diglycerides of fatty acids. Common emulsifiers. Emulsifiers (E471) made from fatty acids. Common in bread and baked goods. Considered safe by most regulatory bodies.',
  'e472a': 'Acetylated mono- and diglycerides. Modified emulsifiers (E472a) used to improve texture in baked goods. Generally considered safe.',
  'e472b': 'Lactic acid esters of mono- and diglycerides. Emulsifiers (E472b) made from lactic acid and fatty acids. Used in whipped products and bread. Generally safe.',
  'e472c': 'Citric acid esters of mono- and diglycerides. Emulsifiers (E472c) used in margarines and dressings. Generally considered safe.',
  'e472e': 'DATEM (diacetyl tartaric acid esters). Diacetyl tartaric acid esters of mono- and diglycerides (E472e). A common bread emulsifier. Generally considered safe.',
  'e473': 'Sucrose esters. Emulsifiers (E473) made from sucrose and fatty acids. Generally safe; used in low-fat products.',
  'e475': 'Polyglycerol esters of fatty acids. Emulsifiers (E475) used in chocolate and bakery products. Generally considered safe.',
  'e481': 'Sodium stearoyl lactylate. An emulsifier (E481) used in bread, cereal, and other baked goods to improve texture and shelf life. Generally considered safe.',
  'e482': 'Calcium stearoyl lactylate. An emulsifier (E482) similar to sodium stearoyl lactylate. Used in baked goods; generally considered safe.',
  'e491': 'Sorbitan monostearate. An emulsifier (E491) used in yeast foods and chocolate coatings. Generally safe; related to polysorbates.',
  'e500': 'Sodium carbonates — used as leavening agents and acidity regulators. Generally safe.',
  'e501': 'Potassium carbonate. An alkaline agent (E501i) used in cocoa processing and noodle making. Generally safe in food amounts.',
  'e503': 'Ammonium carbonates (including ammonium bicarbonate). A leavening agent (E503ii) used in cookies and crackers. Breaks down completely during baking, leaving no residue; generally safe.',
  'e504': 'Magnesium carbonate — anti-caking agent. An anti-caking agent (E504). Generally considered safe; also used as a magnesium supplement.',
  'e551': 'Silicon dioxide — anti-caking agent. A naturally occurring mineral (E551) used as an anti-caking agent in powders. Generally considered inert and safe; nanoparticle forms are under further study.',
  'e901': 'Beeswax — natural glazing agent. A natural wax (E901) used to coat candies and fruits. Generally safe; not suitable for vegans.',
  'e903': 'Carnauba wax — natural glazing agent. A natural wax from palm leaves (E903) used to coat candies, fruits, and tablets. Generally considered safe.',
  'e904': 'Shellac — natural resin glaze. A resin secreted by the lac beetle (E904) used as a glaze on candies and fruits. Generally safe; not suitable for vegans.',
  'e953': 'Isomalt — a sugar alcohol. A sugar alcohol (E953) derived from sucrose. Lower glycemic impact than sugar but can cause digestive issues at high doses.',
  'e966': 'Lactitol — a sugar alcohol. A sugar alcohol (E966) derived from lactose. Used in sugar-free products; can cause bloating and has a laxative effect in excess.',
  'e1520': 'Propylene glycol. A synthetic additive (E1520) used as a solvent, humectant, and preservative. Generally recognized as safe, but large amounts can cause lactic acidosis.',
};