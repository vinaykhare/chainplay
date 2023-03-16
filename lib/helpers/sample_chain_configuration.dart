//SQF Lite initialization SQLs

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';

Map<String, Activity> sampleActivities = {
  /*
    Workout Activities
  */
  "activity_start": Activity(
    activityId: "activity_start",
    title: systemStartActivityInTitle,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    type: systemStartActivityInDB,
  ),
  "activity_rest": Activity(
    activityId: "activity_rest",
    title: systemWaitActivityTitle,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    type: systemWaitActivityInDB,
  ),
  "Jumping Jacks": Activity(
    title: "Jumping Jacks",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "workout_activity_jumping_jacks",
    specification: {
      activitySpecImagePath:
          "https://hips.hearstapps.com/hmg-prod/images/workouts/2016/03/jumpingjack-1457045563.gif?resize=1200:*",
    },
  ),
  "Push Ups & Rotations": Activity(
    title: "Push Ups & Rotations",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "workout_activity_pushups_and_rotations",
    specification: {
      activitySpecImagePath:
          "https://hips.hearstapps.com/hmg-prod/images/workouts/2016/04/tpushup-1461693226.gif?resize=1200:*",
    },
  ),
  "Burpees": Activity(
    title: "Burpees",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "workout_activity_burpees",
    specification: {
      activitySpecImagePath:
          "https://hips.hearstapps.com/hmg-prod/images/workouts/2016/03/burpee-1457045324.gif?resize=1200:*",
    },
  ),
  "Cobra Stretch": Activity(
    title: "Cobra Stretch",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "workout_activity_cobra_stretch",
    specification: {
      activitySpecImagePath:
          "https://img.freepik.com/premium-photo/athletic-woman-doing-cobra-pose-practicing-bhujangasana-yoga-stretching-back-muscles_416530-737.jpg?w=1060",
    },
  ),
  /*
    Medicine Activities
  */

  "Morning Medicine 1": Activity(
    title: "Morning Medicine 1",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "medicine_activity_morning_1",
    specification: {
      activitySpecImagePath:
          "https://onemg.gumlet.io/l_watermark_346,w_690,h_700/a_ignore,w_690,h_700,c_pad,q_auto,f_auto/cropped/uvuvhlzkyiyjhuzm6aoe.jpg",
    },
  ),
  "Morning Medicine 2": Activity(
    title: "Morning Medicine 2",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "medicine_activity_morning_2",
    specification: {
      activitySpecImagePath:
          "https://onemg.gumlet.io/l_watermark_346,w_690,h_700/a_ignore,w_690,h_700,c_pad,q_auto,f_auto/cropped/fbby2iwmvgjnjbuxxm6j.jpg",
    },
  ),
  "Afternoon Medicine 1": Activity(
    title: "Afternoon Medicine 1",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "medicine_activity_afternoon_1",
    specification: {
      activitySpecImagePath:
          "https://onemg.gumlet.io/l_watermark_346,w_690,h_700/a_ignore,w_690,h_700,c_pad,q_auto,f_auto/vrylwtoleb8dpox1fxbq.jpg",
    },
  ),
  "Evening Medicine 1": Activity(
    title: "Evening Medicine 1",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "medicine_activity_evening_1",
    specification: {
      activitySpecImagePath:
          "https://onemg.gumlet.io/l_watermark_346,w_690,h_700/a_ignore,w_690,h_700,c_pad,q_auto,f_auto/cropped/fpxwi4imv9qn4czfkez9.jpg",
    },
  ),
  "Evening Medicine 2": Activity(
    title: "Evening Medicine 2",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "medicine_activity_evening_2",
    specification: {
      activitySpecImagePath:
          "https://onemg.gumlet.io/l_watermark_346,w_690,h_700/a_ignore,w_690,h_700,c_pad,q_auto,f_auto/crou5pg9acjysoeefq4p.jpg",
    },
  ),
  /*
    Diet Activities
  */
  "WakeUp Drinks": Activity(
    title: "WakeUp Drinks",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "diet_activity_wakeup_drinks",
    specification: {
      activitySpecImagePath:
          "https://im.indiatimes.in/media/content/2018/Sep/7_simple_morning_drinks_that_can_help_you_start_your_day_at_your_healthiest_best_1538306484_725x725.jpg",
    },
  ),
  "Breakfast": Activity(
    title: "Breakfast",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "diet_activity_breakfast",
    specification: {
      activitySpecImagePath:
          "https://img.delicious.com.au/-AP1XEox/w759-h506-cfill/del/2021/08/blackberry-pancakes-with-peanut-butter-and-honey-155811-2.jpg",
    },
  ),
  "Lunch": Activity(
    title: "Lunch",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "diet_activity_lunch",
    specification: {
      activitySpecImagePath:
          "https://img-global.cpcdn.com/recipes/af691d91b2468f78/1360x964cq70/simple-lunch-recipe-main-photo.webp",
    },
  ),
  "Evening Snacks": Activity(
    title: "Evening Snacks",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "diet_activity_evening_snacks",
    specification: {
      activitySpecImagePath:
          "https://cdn.shortpixel.ai/spai/w_994+q_lossless+ret_img+to_webp/https://www.mintsrecipes.com/wp-content/uploads/Veg-Poha-Cutlet-Pin.jpg",
    },
  ),
  "Evening Drinks": Activity(
    title: "Evening Drinks",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "diet_activity_evening_drinks",
    specification: {
      activitySpecImagePath:
          "https://www.acouplecooks.com/wp-content/uploads/2021/06/Strawberry-Water-006.jpg",
    },
  ),
  "Dinner": Activity(
    title: "Dinner",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "diet_activity_dinner",
    specification: {
      activitySpecImagePath:
          "https://c.ndtvimg.com/2022-06/ijq8ovbg_how-to-make-veg-makhani-veg-makhanwala_625x300_07_June_22.jpg",
    },
  ),
};

Chain addSampleChainActivities(sampleChain, chainActivityIndices) {
  for (int i = 0; i < chainActivityIndices.length; i++) {
    String activityId = chainActivityIndices[i].keys.toList()[0];
    int activityDuration = chainActivityIndices[i].values.toList()[0];
    sampleChain.activities.add(
      ChainActivity(
        activity: sampleActivities[activityId]!,
        activityDuration: Duration(seconds: activityDuration),
      ),
    );
  }
  return sampleChain;
}

Chain getSampleWorkoutChain(/** List<int> activityIndices */) {
  Chain sampleChain = Chain();
  sampleChain.title = "Sample Workout Chain";

  List<Map<String, int>> chainActivityIndices = [
    {"activity_start": 0},
    {"Jumping Jacks": 30},
    {"activity_rest": 0},
    {"Push Ups & Rotations": 0},
    {"activity_rest": 25},
    {"Burpees": 0},
    {"activity_rest": 15},
    {"Cobra Stretch": 30},
    {"activity_rest": 0},
  ];
  // List<int> chainActivityDurationIndices = [0, 30, 0, 0, 25, 0, 15, 30, 0];

  return addSampleChainActivities(sampleChain, chainActivityIndices);
}

Chain getSampleMedicineChain(/** List<int> activityIndices */) {
  Chain sampleChain = Chain();
  sampleChain.title = "Sample Medicine Routine Chain";

  List<Map<String, int>> chainActivityIndices = [
    {"activity_start": 0},
    {"Morning Medicine 1": 0},
    {"activity_rest": 600},
    {"Morning Medicine 2": 0},
    {"activity_rest": 14400},
    {"Afternoon Medicine 1": 0},
    {"activity_rest": 21600},
    {"Evening Medicine 1": 0},
    {"activity_rest": 3600},
    {"Evening Medicine 2": 0},
    {"activity_rest": 0},
  ];
  // List<int> chainActivityDurationIndices = [0, 30, 0, 0, 25, 0, 15, 30, 0];

  return addSampleChainActivities(sampleChain, chainActivityIndices);
}

Chain getSampleDietChain(/** List<int> activityIndices */) {
  Chain sampleChain = Chain();
  sampleChain.title = "Sample Diet Routine Chain";

  List<Map<String, int>> chainActivityIndices = [
    {"activity_start": 0},
    {"WakeUp Drinks": 0},
    {"activity_rest": 3600},
    {"Breakfast": 0},
    {"activity_rest": 14400},
    {"Lunch": 0},
    {"activity_rest": 14400},
    {"Evening Snacks": 0},
    {"activity_rest": 3600},
    {"Evening Drinks": 0},
    {"activity_rest": 7200},
    {"Dinner": 0},
    {"activity_rest": 0},
  ];
  // List<int> chainActivityDurationIndices = [0, 30, 0, 0, 25, 0, 15, 30, 0];

  return addSampleChainActivities(sampleChain, chainActivityIndices);
}

List<Chain> sampleChains = [
  getSampleWorkoutChain(),
  getSampleMedicineChain(),
  getSampleDietChain()
];
