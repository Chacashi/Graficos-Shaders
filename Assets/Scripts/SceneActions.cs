using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneActions : MonoBehaviour
{
public void ChangueScene(string sceneName)
    {
        SceneManager.LoadScene(sceneName);
    }

    public void Exit()
    {
        Application.Quit();
    }

}
