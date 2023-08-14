# bandopenapi
모든 BAND OPEN API 요청에는 access_token 이라는 이름의 파라메터가 포함됩니다. OPEN API 서버는 이 파라메터에 들어있는 값을 사용하여 이 요청을 한 사용자가 누구인지 판단합니다.
※ A 라는 사용자의 access token을 포함한 요청은 A 사용자의 요청으로 간주됩니다. 따라서 B라는 사용자가 A의 access token을 사용하여 글을 작성하면 그 글은 A 사용자가 올린 글이 됩니다. 따라서 절대로 타인에게 자신의 access token을 노출하면 안 됩니다.

## 이제 나의 access token을 확인할 방법에 대해 이야기하겠습니다.
먼저 밴드 개발자 센터 (https://developers.band.us) 의 내 서비스 ( https://developers.band.us/develop/myapps/list ) 로 접근합니다.
![image-2023-8-14_20-49-10](https://github.com/heetakchoi/bandopenapi/assets/3896162/5f76690d-be97-483f-aed7-0765edfbeef3)
밴드 서비스 로그인이 되어 있지 않았다면 밴드 로그인을 진행합니다.
![image-2023-8-14_20-50-29](https://github.com/heetakchoi/bandopenapi/assets/3896162/e6d0ce47-dd21-4644-be4e-d47c2c2e0bb3)
이후 내 서비스 등록 버튼을 통해 OPEN API 사용 등록을 계속합니다.
![image-2023-8-14_20-54-32](https://github.com/heetakchoi/bandopenapi/assets/3896162/c792c921-e8d3-445e-8e12-cf07f3bc9ab2)
임의의 서비스 이름을 입력하고, 서비스 유형을 선택합니다. Redirect URI는 다른 사람의 access token 발급을 대행해 주는 서비스를 만들 때 사용됩니다. 지금은 임의의 URL을 기입한 후 이용약관에 동의하고 확인을 누릅니다.
![image-2023-8-14_21-3-24](https://github.com/heetakchoi/bandopenapi/assets/3896162/7ce65b40-bf20-4aea-a9cf-780004fef863)
전화번호 연동이 필요하다는 메시지가 나오는 경우
![image-2023-8-14_21-4-55](https://github.com/heetakchoi/bandopenapi/assets/3896162/a6eea2be-721d-4fad-9445-a2a046f966f6)
내 정보 의 로그인 계정 설정에서 휴대폰 번호 연동이 되어 있는지 확인합니다.
![image-2023-8-14_21-8-49](https://github.com/heetakchoi/bandopenapi/assets/3896162/e2c1ddc5-a78b-4231-aa5c-e48bf5a0290f)
정상적으로 등록이 완료되면 방금 작성한 애플리케이션 정보를 확인할 수 있습니다.
![image-2023-8-14_21-17-36](https://github.com/heetakchoi/bandopenapi/assets/3896162/46985646-5bcf-466a-af80-660522b7403b)
![image-2023-8-14_21-19-20](https://github.com/heetakchoi/bandopenapi/assets/3896162/2abc83ce-ab51-4d3e-9e2e-51a65b18eb75)
화면 중 Access Token 메뉴의 밴드 계정 연동을 진행합니다.
![image-2023-8-14_21-23-4](https://github.com/heetakchoi/bandopenapi/assets/3896162/3e42f1e9-16b6-4be4-bda7-80a9ddb1774e)
애플리케이션에 어떠한 권한을 부여할지를 결정하고 동의하면 본인의 계정 권한을 가지는 Access Token 이 발급됩니다.
![image-2023-8-14_21-27-23](https://github.com/heetakchoi/bandopenapi/assets/3896162/27a4c01e-8121-4ee1-91a6-c842199e21d8)
위 예제에서 발급된 Access Token 값은 ZQ...Fb6lmr 임을 확인할 수 있습니다.

이제 본인의 계정에 연결된 Access Token 을 발급받았습니다.
