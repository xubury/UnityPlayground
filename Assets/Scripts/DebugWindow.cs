using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;
using UnityEditor;

public class DebugWindow : EditorWindow
{
    [SerializeField]
    private VisualTreeAsset uxml;


    [MenuItem("EditorTools/DebugWindow")]
    public static void ShowGUI()
    {
        DebugWindow win = GetWindow<DebugWindow>();
        win.titleContent = new GUIContent("DebugWindow");

    }

    static void PrintClickMessage(ClickEvent evt)
    {
        Debug.Log("Click");
    }

    public void CreateGUI()
    {
        if (uxml)
        {
            VisualElement ui = uxml.Instantiate();
            VisualElement root = rootVisualElement;
            root.Add(ui);

            var _button = rootVisualElement.Q("button") as Button;
            _button.RegisterCallback<ClickEvent>(PrintClickMessage);
        }
    }

    public void OnGUI() 
    {
        GUILayout.Space(500);
        if (GUILayout.Button("Press Me"))
        {
            Debug.Log("press me");
        }
    }
}
