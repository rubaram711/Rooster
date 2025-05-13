import 'package:get/get.dart';
import '../../Backend/CategoriesBackend/get_categories.dart';
import '../../Screens/Configuration/categories_dialog.dart';


class CategoriesController extends GetxController {
  int selectedTabIndex=0;
  List categoriesList = [];
  List<String> categoriesNameList = [];
  List categoriesIdsList = [];
  bool isCategoriesFetched = false;
  Map selectedCategory={};
  List<String> subCategoriesNamesList = [];
  List subCategoriesIdsList = [];
  List<String> selectedSubCategories = [];

  setSelectedTabIndex(int val){
    selectedTabIndex=val;
    update();
  }

  getCategoriesFromBack() async {
      categoriesList = [];
      categoriesNameList = [];
      categoriesIdsList = [];
      isCategoriesFetched = false;
      // update();
      var p = await getCategories(searchCategoryController.text);
      for (var cat in p) {
        categoriesNameList.add('${cat['category_name']}');
        categoriesIdsList.add('${cat['id']}');
      }
      categoriesList.addAll(p);
      categoriesList=categoriesList.reversed.toList();
      isCategoriesFetched = true;
      update();
  }


  setSelectedCategory(Map newVal){
    selectedSubCategories=[];
    subCategoriesIdsList=[];
    selectedCategory=newVal;
    oldCatNameController.text=selectedCategory['category_name'];
    for (var cat in selectedCategory['children']) {
      selectedSubCategories.add('${cat['category_name']}');
      subCategoriesIdsList.add('${cat['id']}');
    }
    update();
  }

  setSelectedSubCategories(List<String> newList){
    selectedSubCategories=newList;
    update();
  }
}
