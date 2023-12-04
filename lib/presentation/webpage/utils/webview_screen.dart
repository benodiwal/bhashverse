import 'package:bhashverse/utils/theme/app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewController;
  Map<String, dynamic> args = Get.arguments;
  late String initialUrl = args['url'];
  late String language = args['language'];
  bool isLoading = true;

  late String script = """
    
  const htmlStringToDOM = (html) => {
  const parser = new DOMParser();
  return parser.parseFromString(html, "text/html").body;
};

const IGNORE_NODES = ["SCRIPT", "STYLE"];

const mapNodesAndText = (element, map) => {
  if (
    element &&
    element.nodeType === 3 &&
    element.textContent.trim().replaceAll("\\n", "")
  ) {
    let text = element.textContent.trim();
    if (map.has(text)) {
      map.get(text).push(element);
    } else {
      map.set(text, [element]);
    }
  } else if (
    element &&
    element.nodeType === 1 &&
    !IGNORE_NODES.includes(element.nodeName)
  ) {
    element.childNodes.forEach((child) => {
      mapNodesAndText(child, map);
    });
  }
};

class BhashiniTranslator {
  #pipelineData;
  #apiKey;
  #userID;
  #sourceLanguage;
  #targetLanguage;
  failcount = 0;
  constructor(apiKey, userID) {
    if (!apiKey || !userID) {
      throw new Error("Invalid credentials");
    }
    this.#apiKey = apiKey;
    this.#userID = userID;
  }

  async #getPipeline(sourceLanguage, targetLanguage) {
    this.#sourceLanguage = sourceLanguage;
    this.#targetLanguage = targetLanguage;
    const apiUrl =
      "https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline";

    const response = await fetch(apiUrl, {
      method: "POST",
      headers: {
        ulcaApiKey: this.#apiKey,
        userID: this.#userID,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        pipelineTasks: [
          {
            taskType: "translation",
            config: {
              language: {
                sourceLanguage,
                targetLanguage,
              },
            },
          },
        ],
        pipelineRequestConfig: {
          pipelineId: "64392f96daac500b55c543cd",
        },
      }),
    });

    this.#pipelineData = await response.json();
  }

  async #translate(contents, sourceLanguage, targetLanguage) {
    if (!this.#pipelineData) {
      throw new Error("pipelineData not found");
    }
    const callbackURL =
      this.#pipelineData.pipelineInferenceAPIEndPoint.callbackUrl;
    const inferenceApiKey =
      this.#pipelineData.pipelineInferenceAPIEndPoint.inferenceApiKey.value;
    const serviceId =
      this.#pipelineData.pipelineResponseConfig[0].config.serviceId;
    let resp;
    try {
      const inputArray = contents.map((content) => ({
        source: content,
      }));

      resp = await fetch(callbackURL, {
        method: "POST",
        headers: {
          Authorization: inferenceApiKey,
          "Content-type": "application/json",
        },
        body: JSON.stringify({
          pipelineTasks: [
            {
              taskType: "translation",
              config: {
                language: {
                  sourceLanguage,
                  targetLanguage,
                },
                serviceId,
              },
            },
          ],
          inputData: {
            input: inputArray,
          },
        }),
      }).then((res) => res.json());
    } catch (e) {
      if (this.failcount > 10)
        throw new Error(
          "Failed getting a response from the server after 10 tries"
        );
      this.failcount++;
      this.#getPipeline(sourceLanguage, targetLanguage);
      return await this.#translate(contents, sourceLanguage, targetLanguage);
    }
    try {
      let v = resp.pipelineResponse[0].output;
    } catch (e) {
      if (this.failcount > 10)
        throw new Error(
          "Failed getting a response from the server after 10 tries"
        );
      this.failcount++;
      this.#getPipeline(sourceLanguage, targetLanguage);
      return await this.#translate(contents, sourceLanguage, targetLanguage);
    }
    this.failcount = 0;
    return resp.pipelineResponse[0].output;
  }

  async translateDOM(dom, sourceLanguage, targetLanguage, batchSize) {
    if (
      !this.#pipelineData ||
      this.#sourceLanguage !== sourceLanguage ||
      this.#targetLanguage !== targetLanguage
    ) {
      await this.#getPipeline(sourceLanguage, targetLanguage);
    }

    const map = new Map();
    mapNodesAndText(dom, map);

    const batchedTexts = Array.from(map.keys());
    const batches = [];
    for (let i = 0; i < batchedTexts.length; i += batchSize) {
      batches.push(batchedTexts.slice(i, i + batchSize));
    }

    const promises = batches.map(async (batch) => {
      const combinedText = batch;
      const translated = await this.#translate(
        combinedText,
        this.#sourceLanguage,
        this.#targetLanguage,
        batchSize
      );

      batch.forEach((text, index) => {
        map.get(text).forEach((node) => {
          node.textContent = " " + translated[index].target + " ";
        });
      });
    });

    await Promise.all(promises);

    return dom;
  }

  async translateHTMLstring(html, sourceLanguage, targetLanguage, batchSize) {
    const dom = htmlStringToDOM(html);
    const translated = await this.translateDOM(
      dom,
      sourceLanguage,
      targetLanguage,
      batchSize
    );
    return translated;
  }
  
}

const translator = new BhashiniTranslator('241a2dd58f-4ca2-4239-b6ce-ec64434c32e2', '0fabeaae7e3d4a4684e36e35f3f9b667');

async function main () {
  await translator.translateDOM(document.body, "en", "$language", 22);
}

main().then(result => {
  finished.postMessage("finished");
});

   """;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("finished",
          onMessageReceived: (JavaScriptMessage message) {
        setState(() {
          isLoading = false;
        });
      })
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
        return NavigationDecision.navigate;
      }, onPageFinished: (String url) async {
        await executeJS();
        // if (result) {
        //   await Future.delayed(const Duration(seconds: 15));
        //   setState(() {
        //     isLoading = false;
        //   });
        // }
      }, onPageStarted: (String url) {
        setState(() {
          isLoading = true;
        });
      }))
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..loadRequest(Uri.parse(initialUrl));
  }

  Future<bool> executeJS() async {
    try {
      await _webViewController.runJavaScript(script);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.appTheme.backgroundColor,
        title: Text(
          initialUrl,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: context.appTheme.backgroundColor,
                  ),
                )
              : FutureBuilder<bool>(
                  future: executeJS(),
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        snapshot.data == true ? Icons.check : Icons.error,
                        size: 40.0,
                        color:
                            snapshot.data == true ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WebViewWidget(controller: _webViewController),
        ),
      ),
    );
  }

  // Future<String> fetchHTML(String url) async {
  //   //http.Response content = await http.get(Uri.parse(url));
  //   //await Future.delayed(const Duration(seconds: 3));
  //   String content = await getHtmlString(url);
  //   return content;
  // }

  // Future<String> getHtmlString(String url) async {
  //   const String serverUrl = 'http://192.168.69.64:3000/translate';
  //   try {
  //     final response = await http.post(Uri.parse(serverUrl),
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode({'url': 'https://example.com'}));
  //     if (response.statusCode == 200) {
  //       return response.body;
  //     } else {
  //       print("Not able to fetch");
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return "";
  // }

  // Future<String> getHtmlString(String url) async {
  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     final document = html_parser.parse(response.body);
  //     final bodyElement = document.body;

  //     Map<String, List<dom.Element>> map = {};
  //     mapNodesAndText(bodyElement!, map);

  //     var translationFutures = <Future>[];

  //     for (var entry in map.entries) {
  //       var text = entry.key;
  //       var nodes = entry.value;
  //       var translationFuture = translate(text, "en", "hi").then((translated) {
  //         print(translated);
  //         for (var element in nodes) {
  //           element.text = translated;
  //         }
  //       });
  //       translationFutures.add(translationFuture);
  //     }

  //     await Future.wait(translationFutures);

  //     return bodyElement.outerHtml;
  //   }
  //   return "";
  // }

  // Future<String> getHtmlString(String url) async {
  //   const String userId = "0fabeaae7e3d4a4684e36e35f3f9b667";
  //   const String ulcaApiKey = "241a2dd58f-4ca2-4239-b6ce-ec64434c32e2";

  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     final document = html_parser.parse(response.body);
  //     final bodyElement = document.body;

  //     var translator = BhashiniTranslator(ulcaApiKey, userId);
  //     var content = await translator.translateDOM(document, "en", "hi", 22);
  //     return content.toString();
  //   }
  //   return "";
  // }
}
