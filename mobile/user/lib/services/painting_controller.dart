import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:user/services/api_services.dart';
import '../models/painting.dart';

class PaintingController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<Painting> paintings = <Painting>[].obs;
  final apiService = ApiService().obs;
  bool reachedEndOfList = false;
  bool searchMode = false;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchPaintings();
    // Add a listener to the scrollController to detect when the user reaches the end of the list
    scrollController.addListener(() {
      if (!reachedEndOfList &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent) {
        // Load more data
        loadMorePaintings();
      }
    });
  }

  void fetchPaintings() async {
    searchMode = false;
    isLoading.value = true;
    final res = await apiService.value.getPaintings();

    paintings.value = res!;
    isLoading.value = false;
  }

  void loadMorePaintings() async {
    if (isLoading.value || reachedEndOfList) {
      return;
    }

    isLoading.value = true;
    //page.value++; // Increment the page number

    final res = await apiService.value.getPaintings();

    if (res!.isEmpty) {
      reachedEndOfList = true;
      // Notify the user that there are no more posts for now
      // You can display a message or handle it in your UI accordingly
    } else {
      paintings.addAll(res);
    }

    isLoading.value = false;
    update(); // Trigger UI update
  }

  void searchPainting(String query) async {
    searchMode = true;
    isLoading.value = true;
    final res = await apiService.value.searchPainting(query);
    print(res);
    paintings.value = res!;
    isLoading.value = false;
  }

  void updatePaintingStatus(String id, bool status) {
    final painting = paintings.firstWhere((p) => p.id == id);
    painting.isLikedByUser = status;
    paintings.refresh();
    }

}