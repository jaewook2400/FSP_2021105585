//서버에 존재하는 레시피로, 사용자 정보와 관련이 없음. 로컬이든 뭐든 간에 모든 레시피는 모두 여기 있어야 하며, recipeId를 가져야 함.
final List<Map<String, dynamic>> recipes = [
  {
    "recipeId": 1,
    "name": "계란볶음밥",
    "timeToCook": 15,
    "ingredient": ["계란", "밥"],
    "description": "계란을 이용한 밥 요리입니다.",
    "imageUrl": "http://fiscom/300/400",
    "process": [
      "프라이팬에 기름을 부어 달군다.",
      "계란과 밥을 넣어 볶는다.",
      "기호에 맞게 양념을 추가한다."
    ]
  },
  {
    "recipeId": 2,
    "name": "김치볶음밥",
    "timeToCook": 20,
    "ingredient": ["김치", "밥"],
    "description": "김치를 이용한 밥 요리입니다.",
    "imageUrl": "http://fiscom/300/401",
    "process": [
      "프라이팬에 기름을 두르고 김치를 볶는다.",
      "밥을 넣고 볶는다.",
      "간을 맞춘다."
    ]
  },
  {
    "recipeId": 3,
    "name": "파스타",
    "timeToCook": 25,
    "ingredient": ["면", "소스"],
    "description": "면과 소스로 만드는 요리입니다.",
    "imageUrl": "http://fiscom/300/402",
    "process": [
      "면을 삶는다.",
      "소스를 끓인다.",
      "면과 소스를 섞는다."
    ]
  },
];

//사용자 정보를 나타내는 곳
final Map<String, dynamic> userInfo = {
    'user1': {
        'likedRecipeId': [1, 2],
        'recordedRecipe': [
            {
                "recipeId": 101,
                "name": "계란볶음밥",
                "timeToCook": 15,
                "ingredient": ["계란", "밥"],
                "description": "계란을 이용한 밥 요리입니다.",
                "imageUrl": "http://fiscom/300/400",
                "process": [
                    "프라이팬에 기름을 부어 달군다.",
                    "계란과 밥을 넣어 볶는다.",
                    "기호에 맞게 양념을 추가한다."
                ]
            },
            {
                "recipeId": 102,
                "name": "김치볶음밥",
                "timeToCook": 20,
                "ingredient": ["김치", "밥"],
                "description": "김치를 이용한 밥 요리입니다.",
                "imageUrl": "http://fiscom/300/401",
                "process": [
                    "프라이팬에 기름을 두르고 김치를 볶는다.",
                    "밥을 넣고 볶는다.",
                    "간을 맞춘다."
                ]
            },
        ],
    }
};

//AI가 만들어준 레시피라고 가정하기(지금은 목데이터 사용)
final Map<String, dynamic> aiMadeRecipe = {
    "recipeId": 30,
    "name": "계란볶음밥",
    "timeToCook": 15,
    "ingredient": ["계란", "밥"],
    "description": "계란을 이용한 밥 요리입니다.",
    "imageUrl": "http://fiscom/300/400",
    "process": [
      "프라이팬에 기름을 부어 달군다.",
      "계란과 밥을 넣어 볶는다.",
      "기호에 맞게 양념을 추가한다."
    ]
  };