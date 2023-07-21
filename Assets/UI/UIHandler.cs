using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class UIHandler : MonoBehaviour
{
    private Button _button;
    private Toggle _toggle;

    private void PrintClickMessage(ClickEvent evt)
    {
        Debug.Log(evt.button);
    }

    // Start is called before the first frame update
    void Start()
    {
        var uiDocument = GetComponent<UIDocument>();
        _button = uiDocument.rootVisualElement.Q("button") as Button;
        _toggle = uiDocument.rootVisualElement.Q("toggle") as Toggle;

        _button.RegisterCallback<ClickEvent>(PrintClickMessage);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
