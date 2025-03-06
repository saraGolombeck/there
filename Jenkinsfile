// // // // pipeline {
// // // //     agent any
    
// // // //     parameters {
// // // //         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
// // // //         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
// // // //         string(name: 'PORT_MAPPING', defaultValue: '8080:80@loadbalancer', description: 'מיפוי פורטים')
// // // //     }
    
// // // //     options {
// // // //         timeout(time: 30, unit: 'MINUTES')
// // // //     }
    
// // // //     stages {
// // // //         stage('בדיקת תוכנות נדרשות') {
// // // //             steps {
// // // //                 script {
// // // //                     echo 'בודק אם כלים נדרשים מותקנים...'
                    
// // // //                     def k3dInstalled = sh(script: 'which k3d || echo "NOT_FOUND"', returnStdout: true).trim()
// // // //                     def kubectlInstalled = sh(script: 'which kubectl || echo "NOT_FOUND"', returnStdout: true).trim()
                    
// // // //                     if (k3dInstalled == 'NOT_FOUND') {
// // // //                         error 'K3D לא נמצא. יש להתקין אותו על סוכן Jenkins'
// // // //                     }
                    
// // // //                     if (kubectlInstalled == 'NOT_FOUND') {
// // // //                         error 'kubectl לא נמצא. יש להתקין אותו על סוכן Jenkins'
// // // //                     }
                    
// // // //                     echo 'כל הכלים הנדרשים מותקנים.'
// // // //                 }
// // // //             }
// // // //         }
        
// // // //         stage('מחיקת קלאסטר קיים') {
// // // //             steps {
// // // //                 script {
// // // //                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
// // // //                     echo 'קלאסטר קיים נמחק בהצלחה או לא נמצא.'
// // // //                 }
// // // //             }
// // // //         }
        
// // // //         stage('יצירת קלאסטר חדש') {
// // // //             steps {
// // // //                 script {
// // // //                     // וידוא שתיקיית .kube קיימת
// // // //                     sh "mkdir -p \${HOME}/.kube"
                    
// // // //                     // יצירת הקלאסטר עם הגדרות מינימליות להגברת היציבות
// // // //                     sh """
// // // //                         k3d cluster create ${params.CLUSTER_NAME} \\
// // // //                         --agents 1 \\
// // // //                         --timeout 5m \\
// // // //                         --no-lb \\
// // // //                         --api-port 6443
// // // //                     """
// // // //                     echo 'קלאסטר חדש נוצר בהצלחה.'
                    
// // // //                     // כתיבת ה-kubeconfig למשתנה סביבה ישירות
// // // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config"
// // // //                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-config"
// // // //                     sh "chmod 600 \${HOME}/.kube/k3d-config"
                    
// // // //                     // שימוש ישיר בקובץ ה-kubeconfig שנוצר
// // // //                     sh """
// // // //                         export KUBECONFIG=\${HOME}/.kube/k3d-config
// // // //                         kubectl config use-context k3d-${params.CLUSTER_NAME}
// // // //                         kubectl config view
// // // //                     """
                    
// // // //                     // המתנה ארוכה יותר לאתחול המערכת
// // // //                     sh "sleep 60"
                    
// // // //                     // בדיקת מצב הקלאסטר עם הקובץ החדש
// // // //                     echo "בודק תקשורת עם הקלאסטר..."
// // // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes || true"
                    
// // // //                     // הפעלת בדיקה קצרה ללא תלות בהצלחה
// // // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl cluster-info || true"
                    
// // // //                     // המשך התהליך עם התעלמות משגיאות התחלתיות
// // // //                     echo "ממשיך לשלב הבא..."
// // // //                 }
// // // //             }
// // // //         }
        
// // // //         stage('הגדרת תגיות לצמתים') {
// // // //             steps {
// // // //                 script {
// // // //                     // שימוש בקובץ ה-kubeconfig המפורש
// // // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config"
                    
// // // //                     // המתנה נוספת לוודא שהקלאסטר אכן מוכן
// // // //                     sh "sleep 30"
                    
// // // //                     // בדיקת רשימת הצמתים
// // // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes -o wide || true"
                    
// // // //                     // נסיון לקבלת שמות הצמתים עם טיפול בשגיאות
// // // //                     try {
// // // //                         def nodesJson = sh(script: 'export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes -o json', returnStdout: true).trim()
// // // //                         def nodes = readJSON text: nodesJson
                        
// // // //                         if (nodes.items.size() > 0) {
// // // //                             def masterNode = nodes.items[0].metadata.name
                            
// // // //                             echo "הגדרת שם לשרת הראשון: ${params.CLUSTER_NAME}..."
// // // //                             sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${masterNode} kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite || true"
                            
// // // //                             if (nodes.items.size() > 1) {
// // // //                                 def workerNode = nodes.items[1].metadata.name
// // // //                                 echo "הגדרת שם לשרת השני: ${params.CLUSTER_NAME}-m02..."
// // // //                                 sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${workerNode} kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite || true"
// // // //                             } else {
// // // //                                 echo "נמצא רק צומת אחד בקלאסטר. דילוג על הגדרת התווית לצומת השני."
// // // //                             }
// // // //                         } else {
// // // //                             echo "לא נמצאו צמתים בקלאסטר. דילוג על שלב זה."
// // // //                         }
// // // //                     } catch (Exception e) {
// // // //                         echo "שגיאה בקבלת רשימת הצמתים: ${e.message}. מנסה דרך חלופית..."
                        
// // // //                         // דרך חלופית במקרה של שגיאה
// // // //                         def nodeList = sh(script: 'export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes --no-headers | awk \'{print $1}\'', returnStdout: true).trim()
// // // //                         def nodeArray = nodeList.split('\n')
                        
// // // //                         if (nodeArray.length > 0 && nodeArray[0]) {
// // // //                             echo "הגדרת שם לשרת הראשון: ${params.CLUSTER_NAME}..."
// // // //                             sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${nodeArray[0]} kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite || true"
                            
// // // //                             if (nodeArray.length > 1) {
// // // //                                 echo "הגדרת שם לשרת השני: ${params.CLUSTER_NAME}-m02..."
// // // //                                 sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${nodeArray[1]} kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite || true"
// // // //                             }
// // // //                         } else {
// // // //                             echo "לא ניתן לאתר צמתים בקלאסטר. דילוג על שלב זה."
// // // //                         }
// // // //                     }
// // // //                 }
// // // //             }
// // // //         }
        
// // // //         stage('אימות קלאסטר') {
// // // //             steps {
// // // //                 script {
// // // //                     echo "מציג צמתים ותגיות:"
// // // //                     sh 'export KUBECONFIG=${HOME}/.kube/k3d-config && kubectl get nodes --show-labels || echo "אזהרה: לא ניתן להציג צמתים כרגע"'
                    
// // // //                     echo "בדיקת פודים במרחב kube-system:"
// // // //                     sh 'export KUBECONFIG=${HOME}/.kube/k3d-config && kubectl get pods -n kube-system || echo "אזהרה: לא ניתן להציג פודים כרגע"'
                    
// // // //                     echo "הקלאסטר הוקם בהצלחה!"
// // // //                     echo "1. ${params.CLUSTER_NAME} - עבור מסד הנתונים"
// // // //                     echo "2. ${params.CLUSTER_NAME}-m02 - עבור הבקאנד והפרונטאנד"
                    
// // // //                     // שמירת הגדרת ה-kubeconfig למאוחר יותר
// // // //                     echo "קובץ ה-kubeconfig נמצא ב: ${HOME}/.kube/k3d-config"
// // // //                     echo "כדי להתחבר לקלאסטר, השתמש בפקודה הבאה:"
// // // //                     echo "export KUBECONFIG=${HOME}/.kube/k3d-config && kubectl get nodes"
// // // //                 }
// // // //             }
// // // //         }
// // // //     }
    
// // // //     post {
// // // //         success {
// // // //             echo 'הקמת קלאסטר K3D Kubernetes הושלמה בהצלחה!'
// // // //         }
// // // //         failure {
// // // //             echo 'הקמת קלאסטר K3D Kubernetes נכשלה. בדוק את הלוגים לפרטים נוספים.'
// // // //         }
// // // //         always {
// // // //             echo 'תהליך Jenkins Pipeline הסתיים.'
// // // //         }
// // // //     }
// // // // }

// // // pipeline {
// // //     agent any
    
// // //     parameters {
// // //         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
// // //         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
// // //         string(name: 'PORT_MAPPING', defaultValue: '8080:80@loadbalancer', description: 'מיפוי פורטים')
// // //     }
    
// // //     options {
// // //         timeout(time: 30, unit: 'MINUTES')
// // //     }
    
// // //     stages {
// // //         stage('בדיקת תוכנות נדרשות') {
// // //             steps {
// // //                 script {
// // //                     echo 'בודק אם כלים נדרשים מותקנים...'
                    
// // //                     def k3dInstalled = sh(script: 'which k3d || echo "NOT_FOUND"', returnStdout: true).trim()
// // //                     def kubectlInstalled = sh(script: 'which kubectl || echo "NOT_FOUND"', returnStdout: true).trim()
                    
// // //                     if (k3dInstalled == 'NOT_FOUND') {
// // //                         error 'K3D לא נמצא. יש להתקין אותו על סוכן Jenkins'
// // //                     }
                    
// // //                     if (kubectlInstalled == 'NOT_FOUND') {
// // //                         error 'kubectl לא נמצא. יש להתקין אותו על סוכן Jenkins'
// // //                     }
                    
// // //                     echo 'כל הכלים הנדרשים מותקנים.'
// // //                 }
// // //             }
// // //         }
        
// // //         stage('מחיקת קלאסטר קיים') {
// // //             steps {
// // //                 script {
// // //                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
// // //                     echo 'קלאסטר קיים נמחק בהצלחה או לא נמצא.'
// // //                 }
// // //             }
// // //         }
        
// // //         stage('יצירת קלאסטר חדש') {
// // //             steps {
// // //                 script {
// // //                     // וידוא שתיקיית .kube קיימת
// // //                     sh "mkdir -p \${HOME}/.kube"
                    
// // //                     // יצירת הקלאסטר עם הגדרות מינימליות להגברת היציבות
// // //                     sh """
// // //                         k3d cluster create ${params.CLUSTER_NAME} \\
// // //                         --agents 1 \\
// // //                         --timeout 5m \\
// // //                         --no-lb \\
// // //                         --api-port 6443
// // //                     """
// // //                     echo 'קלאסטר חדש נוצר בהצלחה.'
                    
// // //                     // כתיבת ה-kubeconfig למשתנה סביבה ישירות
// // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config"
// // //                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-config"
// // //                     sh "chmod 600 \${HOME}/.kube/k3d-config"
                    
// // //                     // שימוש ישיר בקובץ ה-kubeconfig שנוצר
// // //                     sh """
// // //                         export KUBECONFIG=\${HOME}/.kube/k3d-config
// // //                         kubectl config use-context k3d-${params.CLUSTER_NAME}
// // //                         kubectl config view
// // //                     """
                    
// // //                     // המתנה ארוכה יותר לאתחול המערכת
// // //                     sh "sleep 60"
                    
// // //                     // בדיקת מצב הקלאסטר עם הקובץ החדש
// // //                     echo "בודק תקשורת עם הקלאסטר..."
// // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes || true"
                    
// // //                     // הפעלת בדיקה קצרה ללא תלות בהצלחה
// // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl cluster-info || true"
                    
// // //                     // המשך התהליך עם התעלמות משגיאות התחלתיות
// // //                     echo "ממשיך לשלב הבא..."
// // //                 }
// // //             }
// // //         }
        
// // //         stage('הגדרת תגיות לצמתים') {
// // //             steps {
// // //                 script {
// // //                     // שימוש בקובץ ה-kubeconfig המפורש
// // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config"
                    
// // //                     // המתנה נוספת לוודא שהקלאסטר אכן מוכן
// // //                     sh "sleep 30"
                    
// // //                     // בדיקת רשימת הצמתים
// // //                     sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes -o wide || true"
                    
// // //                     // נסיון לקבלת שמות הצמתים עם טיפול בשגיאות
// // //                     try {
// // //                         def nodesJson = sh(script: 'export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes -o json', returnStdout: true).trim()
// // //                         def nodes = readJSON text: nodesJson
                        
// // //                         if (nodes.items.size() > 0) {
// // //                             def masterNode = nodes.items[0].metadata.name
                            
// // //                             echo "הגדרת שם לשרת הראשון: ${params.CLUSTER_NAME}..."
// // //                             sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${masterNode} kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite || true"
                            
// // //                             if (nodes.items.size() > 1) {
// // //                                 def workerNode = nodes.items[1].metadata.name
// // //                                 echo "הגדרת שם לשרת השני: ${params.CLUSTER_NAME}-m02..."
// // //                                 sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${workerNode} kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite || true"
// // //                             } else {
// // //                                 echo "נמצא רק צומת אחד בקלאסטר. דילוג על הגדרת התווית לצומת השני."
// // //                             }
// // //                         } else {
// // //                             echo "לא נמצאו צמתים בקלאסטר. דילוג על שלב זה."
// // //                         }
// // //                     } catch (Exception e) {
// // //                         echo "שגיאה בקבלת רשימת הצמתים: ${e.message}. מנסה דרך חלופית..."
                        
// // //                         // דרך חלופית במקרה של שגיאה
// // //                         def nodeList = sh(script: 'export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes --no-headers | awk \'{print $1}\'', returnStdout: true).trim()
// // //                         def nodeArray = nodeList.split('\n')
                        
// // //                         if (nodeArray.length > 0 && nodeArray[0]) {
// // //                             echo "הגדרת שם לשרת הראשון: ${params.CLUSTER_NAME}..."
// // //                             sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${nodeArray[0]} kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite || true"
                            
// // //                             if (nodeArray.length > 1) {
// // //                                 echo "הגדרת שם לשרת השני: ${params.CLUSTER_NAME}-m02..."
// // //                                 sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${nodeArray[1]} kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite || true"
// // //                             }
// // //                         } else {
// // //                             echo "לא ניתן לאתר צמתים בקלאסטר. דילוג על שלב זה."
// // //                         }
// // //                     }
// // //                 }
// // //             }
// // //         }
        
// // //         stage('אימות קלאסטר') {
// // //             steps {
// // //                 script {
// // //                     echo "מציג צמתים ותגיות:"
// // //                     sh 'export KUBECONFIG=${HOME}/.kube/k3d-config && kubectl get nodes --show-labels || echo "אזהרה: לא ניתן להציג צמתים כרגע"'
                    
// // //                     echo "בדיקת פודים במרחב kube-system:"
// // //                     sh 'export KUBECONFIG=${HOME}/.kube/k3d-config && kubectl get pods -n kube-system || echo "אזהרה: לא ניתן להציג פודים כרגע"'
                    
// // //                     echo "הקלאסטר הוקם בהצלחה!"
// // //                     echo "1. ${params.CLUSTER_NAME} - עבור מסד הנתונים"
// // //                     echo "2. ${params.CLUSTER_NAME}-m02 - עבור הבקאנד והפרונטאנד"
                    
// // //                     // שמירת הגדרת ה-kubeconfig למאוחר יותר
// // //                     echo "קובץ ה-kubeconfig נמצא ב: ${HOME}/.kube/k3d-config"
// // //                     echo "כדי להתחבר לקלאסטר, השתמש בפקודה הבאה:"
// // //                     echo "export KUBECONFIG=${HOME}/.kube/k3d-config && kubectl get nodes"
// // //                 }
// // //             }
// // //         }
// // //     }
    
// // //     post {
// // //         success {
// // //             echo 'הקמת קלאסטר K3D Kubernetes הושלמה בהצלחה!'
// // //         }
// // //         failure {
// // //             echo 'הקמת קלאסטר K3D Kubernetes נכשלה. בדוק את הלוגים לפרטים נוספים.'
// // //         }
// // //         always {
// // //             echo 'תהליך Jenkins Pipeline הסתיים.'
// // //         }
// // //     }
// // // }

// // pipeline {
// //     agent any
    
// //     parameters {
// //         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
// //         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
// //         string(name: 'PORT_MAPPING', defaultValue: '8080:80@loadbalancer', description: 'מיפוי פורטים')
// //     }
    
// //     options {
// //         timeout(time: 30, unit: 'MINUTES')
// //     }
    
// //     stages {
// //         stage('מחיקת קלאסטר קיים') {
// //             steps {
// //                 script {
// //                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
// //                 }
// //             }
// //         }
        
// //         stage('יצירת קלאסטר חדש') {
// //             steps {
// //                 script {
// //                     sh "mkdir -p \${HOME}/.kube"
                    
// //                     sh """
// //                         k3d cluster create ${params.CLUSTER_NAME} \\
// //                         --agents 1 \\
// //                         --timeout 5m \\
// //                         --no-lb \\
// //                         --api-port 6443
// //                     """
                    
// //                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-config"
// //                     sh "chmod 600 \${HOME}/.kube/k3d-config"
// //                 }
// //             }
// //         }
        
// //         stage('הגדרת תגיות לצמתים') {
// //             steps {
// //                 script {
// //                     try {
// //                         def nodesJson = sh(script: 'export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes -o json', returnStdout: true).trim()
// //                         def nodes = readJSON text: nodesJson
                        
// //                         if (nodes.items.size() > 0) {
// //                             def masterNode = nodes.items[0].metadata.name
// //                             sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${masterNode} kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite || true"
                            
// //                             if (nodes.items.size() > 1) {
// //                                 def workerNode = nodes.items[1].metadata.name
// //                                 sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${workerNode} kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite || true"
// //                             }
// //                         }
// //                     } catch (Exception e) {
// //                         def nodeList = sh(script: 'export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl get nodes --no-headers | awk \'{print $1}\'', returnStdout: true).trim()
// //                         def nodeArray = nodeList.split('\n')
                        
// //                         if (nodeArray.length > 0 && nodeArray[0]) {
// //                             sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${nodeArray[0]} kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite || true"
                            
// //                             if (nodeArray.length > 1) {
// //                                 sh "export KUBECONFIG=\${HOME}/.kube/k3d-config && kubectl label nodes ${nodeArray[1]} kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite || true"
// //                             }
// //                         }
// //                     }
// //                 }
// //             }
// //         }
// //     }
    
// //     post {
// //         success {
// //             echo 'הקמת קלאסטר K3D Kubernetes הושלמה בהצלחה!'
// //         }
// //         failure {
// //             echo 'הקמת קלאסטר K3D Kubernetes נכשלה.'
// //         }
// //     }
// // }


// pipeline {
//     agent any
    
//     parameters {
//         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
//         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
//         string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'מיפוי פורטים')
//     }
    
//     options {
//         timeout(time: 30, unit: 'MINUTES')
//     }
    
//     stages {
//         stage('מחיקת קלאסטר קיים') {
//             steps {
//                 script {
//                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
//                 }
//             }
//         }
        
//         stage('יצירת קלאסטר חדש') {
//             steps {
//                 script {
//                     sh "mkdir -p \${HOME}/.kube"
                    
//                     // יצירת הקלאסטר עם הגדרות מפורשות ונכונות
//                     sh """
//                         k3d cluster create ${params.CLUSTER_NAME} \\
//                         --agents ${params.NUM_AGENTS} \\
//                         --timeout 5m \\
//                         --api-port 6443 \\
//                         -p "${params.PORT_MAPPING}"
//                     """
                    
//                     // יצירת קובץ kubeconfig מפורש והגדרתו באופן ברור
//                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
//                     sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
//                     // המתנה לייצוב הקלאסטר
//                     sh "sleep 30"
//                 }
//             }
//         }
        
//         stage('הגדרת תגיות לצמתים') {
//             steps {
//                 script {
//                     sh """
//                         export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//                         kubectl config use-context k3d-${params.CLUSTER_NAME}
//                     """
                    
//                     sh "sleep 10"  // המתנה נוספת לוודא שהקלאסטר יציב
                    
//                     sh """
//                         export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
//                         # קבלת רשימת הצמתים
//                         MASTER_NODE=\$(kubectl get nodes --no-headers | head -1 | awk '{print \$1}')
                        
//                         # הגדרת תגית לצומת הראשי
//                         if [ ! -z "\$MASTER_NODE" ]; then
//                             kubectl label nodes \$MASTER_NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
//                         fi
                        
//                         # טיפול בצמתי עבודה (אם יש יותר מצומת אחד)
//                         ADDITIONAL_NODES=\$(kubectl get nodes --no-headers | tail -n +2 | awk '{print \$1}')
//                         if [ ! -z "\$ADDITIONAL_NODES" ]; then
//                             NODE_INDEX=2
//                             echo "\$ADDITIONAL_NODES" | while read -r NODE; do
//                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m0\$NODE_INDEX --overwrite
//                                 NODE_INDEX=\$((NODE_INDEX + 1))
//                             done
//                         fi
//                     """
//                 }
//             }
//         }
        
//         stage('אימות הקלאסטר') {
//             steps {
//                 script {
//                     sh """
//                         export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
//                         echo "בדיקת הקלאסטר שנוצר:"
//                         kubectl cluster-info
                        
//                         echo "רשימת צמתים:"
//                         kubectl get nodes
                        
//                         echo "תגיות הצמתים:"
//                         kubectl get nodes --show-labels
                        
//                         echo "מצב רכיבי המערכת:"
//                         kubectl get pods -n kube-system
//                     """
//                 }
//             }
//         }
//     }
    
//     post {
//         success {
//             echo """
//             הקמת קלאסטר K3D Kubernetes הושלמה בהצלחה!
            
//             להתחברות לקלאסטר, השתמש בפקודה:
//             export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//             kubectl get nodes
//             """
//         }
//         failure {
//             echo 'הקמת קלאסטר K3D Kubernetes נכשלה.'
//         }
//     }
// }




/////MIINKUBE


pipeline {
    agent any
    
    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'minikube', description: 'שם הפרופיל של Minikube')
        string(name: 'KUBERNETES_VERSION', defaultValue: 'v1.27.3', description: 'גרסת Kubernetes')
        string(name: 'MEMORY', defaultValue: '2048', description: 'זיכרון RAM במגה-בייט')
        string(name: 'CPU', defaultValue: '2', description: 'מספר ליבות CPU')
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('מחיקת קלאסטר קיים') {
            steps {
                script {
                    sh """
                        # מחיקת פרופיל קיים (אם יש)
                        minikube delete -p ${params.CLUSTER_NAME} || true
                    """
                }
            }
        }
        
        stage('הקמת קלאסטר Minikube') {
            steps {
                script {
                    sh """
                        # יצירת תיקיית קונפיגורציה
                        mkdir -p \${HOME}/.kube
                        
                        # הפעלת Minikube עם דרייבר Docker
                        minikube start \\
                          -p ${params.CLUSTER_NAME} \\
                          --kubernetes-version=${params.KUBERNETES_VERSION} \\
                          --driver=docker \\
                          --memory=${params.MEMORY} \\
                          --cpus=${params.CPU} \\
                          --embed-certs
                        
                        # יצירת קובץ kubeconfig נפרד
                        minikube update-context -p ${params.CLUSTER_NAME}
                        cp \${HOME}/.kube/config \${HOME}/.kube/minikube-config
                        chmod 600 \${HOME}/.kube/minikube-config
                        
                        # המתנה לייצוב הקלאסטר
                        sleep 30
                    """
                }
            }
        }
        
        stage('הפעלת שירותים בסיסיים') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/minikube-config
                        
                        # הפעלת dashboard (אופציונלי)
                        minikube -p ${params.CLUSTER_NAME} addons enable dashboard
                        
                        # הפעלת metrics-server (אופציונלי)
                        minikube -p ${params.CLUSTER_NAME} addons enable metrics-server
                        
                        # הפעלת ingress (אופציונלי)
                        minikube -p ${params.CLUSTER_NAME} addons enable ingress
                    """
                }
            }
        }
        
        stage('אימות הקלאסטר') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/minikube-config
                        
                        echo "פרטי הקלאסטר:"
                        minikube -p ${params.CLUSTER_NAME} status
                        
                        echo "רשימת הצמתים:"
                        kubectl get nodes
                        
                        echo "שירותי המערכת:"
                        kubectl get pods -n kube-system
                        
                        echo "מידע על הקלאסטר:"
                        kubectl cluster-info
                    """
                }
            }
        }
        
        stage('הגדרת תגיות על הצמתים') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/minikube-config
                        
                        # קבלת שם הצומת
                        NODE_NAME=\$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
                        
                        # הוספת תגית לצומת
                        kubectl label node \$NODE_NAME kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
                        
                        echo "תגיות הצומת:"
                        kubectl get nodes --show-labels
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo """
            קלאסטר Minikube הוקם בהצלחה!
            
            להתחברות לקלאסטר, השתמש בפקודות הבאות:
            export KUBECONFIG=\${HOME}/.kube/minikube-config
            kubectl get nodes
            
            לגישה ל-dashboard, הרץ:
            minikube -p ${params.CLUSTER_NAME} dashboard
            """
        }
        failure {
            echo 'הקמת קלאסטר Minikube נכשלה. בדוק את הלוגים לקבלת מידע נוסף.'
        }
        always {
            echo 'תהליך Jenkins Pipeline הסתיים.'
        }
    }
}