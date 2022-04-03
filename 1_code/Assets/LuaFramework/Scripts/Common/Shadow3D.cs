using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shadow3D : MonoBehaviour
{
    Transform parentTransform;
    public Vector3 positive = new Vector3(0.3f, -0.3f, 5f);
    Vector3 negative;
    public string parentName = "fish3d";

    void Start()
    {
    	negative = new Vector3(-1*positive.x, -1*positive.y, positive.z);
        parentTransform = transform.parent.Find(parentName);
    }

    void Update()
    {
        //判断是否做了旋转
        if (Camera.main.transform.eulerAngles.z != 0)
        {
            this.transform.position = parentTransform.position + negative;
        }
        else
        {
            this.transform.position = parentTransform.position + positive;
        }
    }
}
