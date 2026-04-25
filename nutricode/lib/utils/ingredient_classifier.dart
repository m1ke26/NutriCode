import '../services/open_food_facts_service.dart';

/// Shared ingredient classification logic used by both VerdictScreen and ProductScreen.

/// Shared ingredient classification logic used by both VerdictScreen and ProductScreen.

// Harmful ingredients (worst — red)
const badIngredients = {
  // Sweeteners & Syrups
  'high fructose corn syrup', 'aspartame', 'acesulfame k', 'acesulfame',
  'saccharin', 'sucralose', 'neotame', 'cyclamate', 'advantame',
  'alitame',

  // Preservatives & Additives
  'sodium nitrite', 'sodium nitrate',
  'butylated hydroxyanisole', 'bha', 'butylated hydroxytoluene', 'bht',
  'potassium bromate', 'azodicarbonamide', 'propyl paraben',
  'methyl paraben', 'ethyl paraben', 'butyl paraben',
  'dimethyl dicarbonate',
  'tertiary butylhydroquinone', 'tbhq',

  // Dyes & Colors
  'tartrazine', 'red 40', 'yellow 5', 'yellow 6', 'blue 1', 'blue 2', 'green 3',
  'red 2', 'red 3', 'red dye', 'erythrosine', 'brilliant blue', 'allura red',
  'sunset yellow', 'ponceau 4r', 'quinoline yellow', 'carmoisine', 'patent blue v',
  'titanium dioxide', 'caramel colour', 'caramel color',

  // Fats & Oils
  'trans fat', 'hydrogenated', 'partially hydrogenated',
  'partially hydrogenated oil', 'interesterified', 'interesterified fat',

  // Emulsifiers & Thickeners
  'polysorbate 80', 'polysorbate 60', 'polysorbate 65',

  // Nitrates/Nitrites (extended)
  'potassium nitrate', 'potassium nitrite',

  // E-numbers (Harmful)
  'e102', 'e104', 'e110', 'e122', 'e123', 'e124', 'e127', 'e129',
  'e131', 'e132', 'e133', 'e143', 'e150c', 'e150d', 'e171',
  'e218', 'e242', 'e249', 'e250', 'e252',
  'e319', 'e320', 'e321',
  'e433', 'e435', 'e436',
  'e950', 'e951', 'e952', 'e954', 'e955',
};

// Moderate concern ingredients (yellow)
const moderateIngredients = {
  // Sugars & Sweeteners
  'sugar', 'glucose syrup', 'fructose', 'sucrose', 'dextrose', 'corn syrup',
  'agave nectar', 'agave syrup', 'honey', 'maple syrup', 'rice syrup',
  'brown rice syrup', 'coconut sugar', 'coconut nectar', 'date sugar', 'date syrup',
  'molasses', 'blackstrap molasses', 'treacle', 'golden syrup',
  'barley malt syrup', 'malt extract', 'invert sugar',
  'maltitol', 'erythritol', 'xylitol', 'sorbitol', 'mannitol',
  'isomalt', 'lactitol',
  'stevia extract', 'steviol glycosides', 'monk fruit extract',

  // Salts
  'salt', 'sodium', 'sea salt', 'rock salt', 'himalayan pink salt',
  'kosher salt', 'celery salt', 'onion salt', 'garlic salt',
  'monosodium glutamate (msg)', 'sodium bicarbonate', 'baking soda', 'baking powder',

  // Oils & Fats
  'palm oil', 'palm kernel oil', 'sunflower oil', 'high oleic sunflower oil',
  'rapeseed oil', 'vegetable oil', 'canola oil', 'soybean oil',
  'corn oil', 'cottonseed oil', 'coconut oil', 'shea butter', 'cocoa butter',
  'lard', 'beef tallow', 'ghee', 'butter', 'margarine', 'shortening',
  'mineral oil', 'rice bran oil', 'flaxseed oil', 'sesame oil',
  'peanut oil', 'avocado oil', 'olive oil',

  // Starches & Maltodextrins
  'maltodextrin', 'modified starch', 'corn starch', 'potato starch',
  'tapioca starch', 'wheat starch', 'rice starch', 'arrowroot', 'dextrin',
  'cyclodextrin',

  // Dairy & Proteins
  'skim milk powder', 'whey powder', 'whey protein', 'casein',
  'sodium caseinate', 'calcium caseinate', 'milk solids', 'lactose',
  'lactalbumin', 'egg white powder', 'egg yolk powder', 'whole egg powder',
  'soy protein', 'soy protein isolate', 'soy protein concentrate',
  'pea protein', 'rice protein', 'hydrolysed vegetable protein',
  'hydrolyzed vegetable protein', 'textured vegetable protein', 'tvp', 'gelatin',

  // Acids
  'citric acid', 'malic acid', 'ascorbic acid', 'lactic acid',
  'tartaric acid', 'acetic acid', 'gluconic acid', 'fumaric acid', 'adipic acid',

  // Leavening Agents
  'cream of tartar', 'sodium acid pyrophosphate', 'monocalcium phosphate',
  'ammonium bicarbonate', 'calcium carbonate', 'potassium carbonate',

  // Flavorings
  'natural flavour', 'natural flavor', 'natural flavouring', 'natural flavoring',
  'flavouring', 'flavoring', 'yeast extract', 'autolyzed yeast', 'hydrolysed yeast',
  'smoke flavour', 'smoke flavor', 'vanilla extract', 'vanillin', 'ethyl vanillin',
  'diacetyl',

  // Gums & Thickeners
  'xanthan gum', 'guar gum', 'locust bean gum', 'pectin',
  'agar', 'agar-agar', 'gellan gum', 'konjac', 'konjac gum',
  'methylcellulose', 'hydroxypropyl methylcellulose', 'hydroxypropyl cellulose',
  'microcrystalline cellulose', 'sodium alginate', 'potassium alginate',
  'calcium alginate', 'arabic gum', 'acacia gum', 'tara gum', 'cassia gum',
  'cellulose gum',

  // Emulsifiers & Others
  'emulsifier', 'stabiliser', 'stabilizer', 'thickener', 'acidity regulator',
  'anti-caking agent', 'preservative', 'lecithin', 'soy lecithin', 'sunflower lecithin',
  'mono- and diglycerides', 'monoglycerides', 'diglycerides',
  'acetylated mono- and diglycerides', 'lactic acid esters', 'citric acid esters',
  'diacetyltartaric acid esters', 'datem', 'sucrose esters',
  'polyglycerol esters', 'sorbitan monostearate', 'sorbitan tristearate',
  'ammonium phosphatides', 'stearoyl lactylates',
  'sodium stearoyl lactylate', 'calcium stearoyl lactylate',

  // Antioxidants
  'vitamin e', 'tocopherol', 'mixed tocopherols', 'alpha-tocopherol',
  'rosemary extract', 'ascorbyl palmitate',

  // Minerals & Vitamins (fortification)
  'iron', 'zinc', 'calcium', 'niacin', 'thiamin', 'thiamine', 'riboflavin',
  'folic acid', 'folate', 'vitamin b6', 'vitamin b12',
  'vitamin d', 'vitamin d2', 'vitamin d3', 'vitamin a',

  // Humectants
  'glycerol', 'glycerin',

  // Bulking Agents & Fiber
  'inulin', 'chicory root', 'chicory root fiber', 'chicory root extract',
  'fructooligosaccharides', 'fos', 'galactooligosaccharides', 'gos',
  'resistant starch', 'oat fiber', 'wheat fiber', 'pea fiber', 'apple fiber',
  'psyllium husk', 'cellulose',

  // Anti-caking & Processing Aids
  'silicon dioxide', 'magnesium carbonate', 'calcium silicate', 'magnesium stearate',
  'sodium ferrocyanide', 'potassium ferrocyanide', 'tricalcium phosphate', 'kaolin',

  // Glazing & Wax Coatings
  'carnauba wax', 'beeswax', 'shellac', 'paraffin wax',

  // Carbonation
  'carbon dioxide',

  // Relocated Additives (previously flagged as Harmful, but FDA/EFSA GRAS)
  'monosodium glutamate', 'msg', 'disodium guanylate', 'disodium inosinate', 'disodium ribonucleotides',
  'sodium benzoate', 'potassium benzoate', 'benzoic acid',
  'sodium metabisulfite', 'potassium metabisulfite', 'sulfur dioxide',
  'calcium propionate', 'sodium propionate', 'propionic acid',
  'potassium sorbate', 'sorbic acid', 'sodium sorbate',
  'natamycin', 'nisin',
  'carmine', 'annatto', 'copper complexes of chlorophylls',
  'artificial sweetener', 'artificial flavour', 'artificial flavor',
  'artificial colour', 'artificial color',
  'propylene glycol', 'carrageenan', 'carboxymethyl cellulose', 'sodium carboxymethyl cellulose',
  'sodium phosphate', 'phosphoric acid', 'dipotassium phosphate',
  'trisodium phosphate', 'sodium hexametaphosphate', 'sodium tripolyphosphate',

  // E-numbers (Moderate)
  'e101', 'e120', 'e160a', 'e160b', 'e163', 'e170',
  'e200', 'e202', 'e210', 'e211', 'e212', 'e220', 'e223', 'e224',
  'e234', 'e235',
  'e260', 'e270', 'e280', 'e281', 'e282', 'e296', 'e297',
  'e300', 'e301', 'e302', 'e304', 'e306', 'e307',
  'e322', 'e330', 'e331', 'e332', 'e334', 'e336', 'e338', 'e339', 'e340', 'e341',
  'e401', 'e406', 'e407', 'e410', 'e412', 'e414', 'e415', 'e418',
  'e420', 'e421', 'e422', 'e440',
  'e451', 'e452',
  'e460', 'e461', 'e464', 'e466',
  'e471', 'e472a', 'e472b', 'e472c', 'e472e', 'e473', 'e475',
  'e481', 'e482', 'e491',
  'e500', 'e501', 'e503', 'e504', 'e551',
  'e621', 'e627', 'e631', 'e635',
  'e901', 'e903', 'e904',
  'e953', 'e960', 'e966', 'e1520',
};

/// Classification levels, ordered from best to worst.
enum IngredientLevel { good, moderate, bad }

/// Classify a single ingredient string.
IngredientLevel classifyIngredient(String ingredient, List<String> allergens) {
  final lower = ingredient.toLowerCase().trim();

  // Allergen checks for color marking have been temporarily decoupled per user request.

  for (final bad in badIngredients) {
    if (RegExp(r'\b' + RegExp.escape(bad) + r'\b').hasMatch(lower)) return IngredientLevel.bad;
  }
  for (final mod in moderateIngredients) {
    if (RegExp(r'\b' + RegExp.escape(mod) + r'\b').hasMatch(lower)) return IngredientLevel.moderate;
  }
  return IngredientLevel.good;
}

/// Determine the worst-case verdict across all ingredients.
/// Returns [IngredientLevel.good] if the list is empty (no data to flag).
IngredientLevel worstCaseVerdict(List<Ingredient> ingredients, List<String> allergens) {
  var worst = IngredientLevel.good;
  for (final ingredient in ingredients) {
    // Check the ingredient itself
    final textToClassify = ingredient.englishText.isNotEmpty ? ingredient.englishText : ingredient.text;
    final level = classifyIngredient(textToClassify, allergens);
    if (level == IngredientLevel.bad) return IngredientLevel.bad;
    if (level == IngredientLevel.moderate) worst = IngredientLevel.moderate;

    // Recursively check sub-ingredients
    if (ingredient.subIngredients.isNotEmpty) {
      final subWorst = worstCaseVerdict(ingredient.subIngredients, allergens);
      if (subWorst == IngredientLevel.bad) return IngredientLevel.bad;
      if (subWorst == IngredientLevel.moderate) worst = IngredientLevel.moderate;
    }
  }
  return worst;
}
